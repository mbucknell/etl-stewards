show user;
select * from global_name;
set timing on;
set serveroutput on;
whenever sqlerror exit failure rollback;
whenever oserror exit failure rollback;
select 'start time: ' || systimestamp from dual;

truncate table organization_temp;

insert /*+ append nologging parallel 4*/ into organization_temp (code_value, description, organization_details, sort_order)
select code_value,
       description,
       xmlelement("OrganizationDescription",
                  xmlelement("OrganizationIdentifier", code_value),
                  xmlelement("OrganizationFormalName", description)
                 ),
       rownum sort_order
  from (select code_value, description, details,
               dense_rank() over (partition by code_value order by description, rownum) myrank
          from (select xmlcast(xmlquery('WQX/Organization/OrganizationDescription/OrganizationIdentifier' passing raw_xml returning content) as varchar2(2000 char)) code_value,
                       xmlcast(xmlquery('WQX/Organization/OrganizationDescription/OrganizationFormalName' passing raw_xml returning content) as varchar2(2000 char)) description,
                       deletexml(raw_xml, 'WQX/Organization/MonitoringLocation') details
                  from stewards_raw_xml
                 where file_name like '%station.xml' and
                       load_timestamp = (select max(load_timestamp) from stewards_raw_xml where file_name like '%station.xml')
               )
       )
 where myrank = 1
   order by 1;
   
commit;

truncate table station_temp;

insert /*+ append nologging parallel 4*/ into station_temp (station_pk, station_id, station_details, country_cd, county_cd, geom, huc_8, organization_id, state_cd, site_type)
select rownum,
       organization_id || '-' || station_id,
       updatexml(station_details, 'MonitoringLocation/MonitoringLocationIdentity/MonitoringLocationIdentifier/text()', organization_id || '-' || station_id) station_details,
       country_cd,
       county_cd,
       mdsys.sdo_geometry(2001,8265,mdsys.sdo_point_type(round(longitude, 7),round(latitude, 7), null), null, null) geom,
       huc_8,
       organization_id,
       state_cd,
       site_type
  from stewards_raw_xml,
       xmltable('/WQX/Organization'
                passing raw_xml
                columns organization_id varchar2(500 char) path '/Organization/OrganizationDescription/OrganizationIdentifier',
                        details xmltype path '/Organization'), 
       xmltable(
                'for $i in /Organization return $i/MonitoringLocation'
                passing details
                columns station_id varchar2(100 char) path '/MonitoringLocation/MonitoringLocationIdentity/MonitoringLocationIdentifier',
                        country_cd varchar2(2 char) path '/MonitoringLocation/MonitoringLocationGeospatial/CountryCode',
                        county_cd varchar2(3 char) path '/MonitoringLocation/MonitoringLocationGeospatial/CountyCode',
                        huc_8 varchar2(8 char) path '/MonitoringLocation/MonitoringLocationIdentity/HUCEightDigitCode',
                        state_cd varchar2(2 char) path '/MonitoringLocation/MonitoringLocationGeospatial/StateCode',
                        site_type varchar2(500 char) path '/MonitoringLocation/MonitoringLocationIdentity/MonitoringLocationTypeName',
                        latitude number path '/MonitoringLocation/MonitoringLocationGeospatial/LatitudeMeasure',
                        longitude number path '/MonitoringLocation/MonitoringLocationGeospatial/LongitudeMeasure',
                        station_details xmltype path '/MonitoringLocation')
 where file_name like '%station.xml' and
       load_timestamp = (select max(load_timestamp) from stewards_raw_xml where file_name like '%station.xml');

commit;

truncate table activity_temp;

truncate table result_temp; 

insert all /*+ append nologging parallel 4*/    
  into activity_temp
    values (activity_pk, activity_details, station_pk, organization_id, station_id, activity_start, activity_id) 
  into result_temp
    values (result_id, results, activity_pk, station_pk, station_id, activity_start, characteristic_name, country_cd, county_cd, huc_8, organization_id, sample_media, state_cd, site_type) 
select activity_pk,
       activity_id,
              updatexml(station_details, 'Activity/ActivityDescription/MonitoringLocationIdentifier/text()', station_id) activity_details,
       station.station_pk,
       station.organization_id,
       station.station_id,
       activity_start,
       result_id,
       results,
       characteristic_name,
       station.country_cd,
       station.county_cd,
       station.huc_8,
       sample_media,
       station.state_cd,
       station.site_type
  from (select activity_pk,
               xmlelement("Activity", xmlconcat(ActivityDescription, SampleDescription)) activity_details,
               to_date(activity_start_date||' '||activity_start_time, 'mm/dd/yyyy hh24:mi:ss') activity_start,
               rownum result_id,
               results,
               characteristic_name,
               sample_media,
               xmlquery('/WQX/Organization/OrganizationDescription/OrganizationIdentifier/text()' passing raw_xml returning content) || '-' || station_id station_id,
               activity_id
          from stewards_raw_xml,
               xmltable('/WQX/Organization/Activity'
                        passing raw_xml
                        columns activity_pk for ordinality,
                                activity xmltype path '/'
                       ) x,
               xmltable('/'
                        passing x.activity
                        columns station_id varchar2(100 char) path '/Activity/ActivityDescription/MonitoringLocationIdentifier',
                                activity_start_date varchar2(8 char) path '/Activity/ActivityDescription/ActivityStartDate',
                                activity_start_time varchar2(8 char) path '/Activity/ActivityDescription/ActivityStartTime/Time',
                                ActivityDescription xmltype path '/Activity/ActivityDescription',
                                SampleDescription xmltype path '/Activity/SampleDescription',
                                results xmltype path '/Activity/Result',
                                characteristic_name varchar2(32 char) path '/Activity/Result/ResultDescription/CharacteristicName',
                                sample_media varchar2(30 char) path '/Activity/ActivityDescription/ActivityMediaName',
                                activity_id varchar2(30 char) path '/Activity/ActivityDescription/ActivityIdentifier'
                       ) y
         where file_name like '%result.xml' and
               load_timestamp = (select max(load_timestamp) from stewards_raw_xml where file_name like '%result.xml')
       ) a
       join station_temp station
         on station.station_id = a.station_id;

commit; 

select 'end time: ' || systimestamp from dual;
