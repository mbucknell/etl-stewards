show user;
select * from global_name;
set timing on;
set serveroutput on;
whenever sqlerror exit failure rollback;
whenever oserror exit failure rollback;
select 'transform result start time: ' || systimestamp from dual;

prompt dropping stewards activity indexes
exec etl_helper_activity.drop_indexes('stewards');

prompt dropping stewards result indexes
exec etl_helper_result.drop_indexes('stewards');

prompt truncate stewards activity
truncate table activity_swap_stewards;

prompt truncate stewards result
truncate table result_swap_stewards;

prompt populating stewards activity and result
insert /*+ append parallel(4) */ all
  into activity_swap_stewards (data_source_id, data_source, station_id, site_id, event_date, activity,
                               sample_media, organization, site_type, huc, governmental_unit_code,
                               organization_name, activity_id, activity_type_code, activity_media_subdiv_name, activity_start_time,
                               act_start_time_zone, activity_stop_date, activity_stop_time, act_stop_time_zone, activity_depth,
                               activity_depth_unit, activity_depth_ref_point, activity_upper_depth, activity_upper_depth_unit,
                               activity_lower_depth, activity_lower_depth_unit, project_id,
                               activity_conducting_org, activity_comment, sample_aqfr_name, hydrologic_condition_name, hydrologic_event_name,
                               sample_collect_method_id, sample_collect_method_ctx, sample_collect_method_name, sample_collect_equip_name)
                       values (data_source_id, data_source, station_id, site_id, event_date, activity,
                               sample_media, organization, site_type, huc, governmental_unit_code,
                               organization_name, activity_id, activity_type_code, activity_media_subdiv_name, activity_start_time,
                               act_start_time_zone, activity_stop_date, activity_stop_time, act_stop_time_zone, activity_depth,
                               activity_depth_unit, activity_depth_ref_point, activity_upper_depth, activity_upper_depth_unit,
                               activity_lower_depth, activity_lower_depth_unit, project_id,
                               activity_conducting_org, activity_comment, sample_aqfr_name, hydrologic_condition_name, hydrologic_event_name,
                               sample_collect_method_id, sample_collect_method_ctx, sample_collect_method_name, sample_collect_equip_name)
  into result_swap_stewards (data_source_id, data_source, station_id, site_id, event_date, analytical_method, p_code, activity,
                             characteristic_name, characteristic_type, sample_media, organization, site_type, huc, governmental_unit_code,
                             organization_name, activity_id, activity_type_code, activity_media_subdiv_name, activity_start_time,
                             act_start_time_zone, activity_stop_date, activity_stop_time, act_stop_time_zone, activity_depth,
                             activity_depth_unit, activity_depth_ref_point, activity_upper_depth, activity_upper_depth_unit,
                             activity_lower_depth, activity_lower_depth_unit, project_id,
                             activity_conducting_org, activity_comment, sample_aqfr_name, hydrologic_condition_name, hydrologic_event_name,
                             sample_collect_method_id, sample_collect_method_ctx, sample_collect_method_name, sample_collect_equip_name,
                             result_id, result_detection_condition_tx, sample_fraction_type, result_measure_value, result_unit,
                             result_meas_qual_code, result_value_status, statistic_type, result_value_type, weight_basis_type, duration_basis,
                             temperature_basis_level, particle_size, precision, result_comment, result_depth_meas_value,
                             result_depth_meas_unit_code, result_depth_alt_ref_pt_txt, sample_tissue_taxonomic_name,
                             sample_tissue_anatomy_name, analytical_procedure_id, analytical_procedure_source, analytical_method_name,
                             analytical_method_citation, lab_name, analysis_start_date, lab_remark, detection_limit, detection_limit_unit,
                             detection_limit_desc, analysis_prep_date_tx)
                     values (data_source_id, data_source, station_id, site_id, event_date, analytical_method, p_code, activity,
                             characteristic_name, characteristic_type, sample_media, organization, site_type, huc, governmental_unit_code,
                             organization_name, activity_id, activity_type_code, activity_media_subdiv_name, activity_start_time,
                             act_start_time_zone, activity_stop_date, activity_stop_time, act_stop_time_zone, activity_depth,
                             activity_depth_unit, activity_depth_ref_point, activity_upper_depth, activity_upper_depth_unit,
                             activity_lower_depth, activity_lower_depth_unit, project_id,
                             activity_conducting_org, activity_comment, sample_aqfr_name, hydrologic_condition_name, hydrologic_event_name,
                             sample_collect_method_id, sample_collect_method_ctx, sample_collect_method_name, sample_collect_equip_name,
                             result_id, result_detection_condition_tx, sample_fraction_type, result_measure_value, result_unit,
                             result_meas_qual_code, result_value_status, statistic_type, result_value_type, weight_basis_type, duration_basis,
                             temperature_basis_level, particle_size, precision, result_comment, result_depth_meas_value,
                             result_depth_meas_unit_code, result_depth_alt_ref_pt_txt, sample_tissue_taxonomic_name,
                             sample_tissue_anatomy_name, analytical_procedure_id, analytical_procedure_source, analytical_method_name,
                             analytical_method_citation, lab_name, analysis_start_date, lab_remark, detection_limit, detection_limit_unit,
                             detection_limit_desc, analysis_prep_date_tx)
select 1 data_source_id,
       s.data_source,
       s.station_id,
       s.site_id,
       to_date(result.activity_start_date, 'mm/dd/yyyy') event_date,
       null analytical_method,
       null p_code,
       result.activity_identifier activity,
       result.characteristic_name,
       char_name_to_type.characteristic_type,
       result.sample_media,
       s.organization,
       s.site_type,
       s.huc,
       s.governmental_unit_code,
       result.organization_name,
       result.activity_id,
       result.activity_type_code,
       result.activity_media_subdiv_name,
       result.activity_start_time,
       result.act_start_time_zone,
       result.activity_stop_date,
       result.activity_stop_time,
       result.act_stop_time_zone,
       result.activity_depth,
       result.activity_depth_unit,
       result.activity_depth_ref_point,
       result.activity_upper_depth,
       result.activity_upper_depth_unit,
       result.activity_lower_depth,
       result.activity_lower_depth_unit,
       result.project_id,
       result.activity_conducting_org,
       result.activity_comment,
       result.sample_aqfr_name,
       result.hydrologic_condition_name,
       result.hydrologic_event_name,
       result.sample_collect_method_id,
       result.sample_collect_method_ctx,
       result.sample_collect_method_name,
       result.sample_collect_equip_name,
       rownum result_id,
       result.result_detection_condition_tx,
       result.sample_fraction_type,
       result.result_measure_value,
       result.result_unit,
       result.result_meas_qual_code,
       result.result_value_status,
       result.statistic_type,
       result.result_value_type,
       result.weight_basis_type,
       result.duration_basis,
       result.temperature_basis_level,
       result.particle_size,
       result.precision,
       result.result_comment,
       result.result_depth_meas_value,
       result.result_depth_meas_unit_code,
       result.result_depth_alt_ref_pt_txt,
       result.sample_tissue_taxonomic_name,
       result.sample_tissue_anatomy_name,
       result.analytical_procedure_id,
       result.analytical_procedure_source,
       result.analytical_method_name,
       result.analytical_method_citation,
       result.lab_name,
       result.analysis_date_time analysis_start_date,
       result.lab_remark,
       result.detection_limit,
       result.detection_limit_unit,
       result.detection_limit_desc,
       result.analysis_prep_date_tx
  from (select *
          from (select organization.*, activity.*, rownum activity_id
                  from ars_stewards.raw_result_xml,
                       xmltable('/WQX/Organization'
                                passing raw_xml
                                columns organization varchar2(500 char) path '/Organization/OrganizationDescription/OrganizationIdentifier',
                                        organization_name varchar2(2000 char) path '/Organization/OrganizationDescription/OrganizationFormalName',
                                        organization_details xmltype path '/Organization') organization, 
                       xmltable('for $i in /Organization return $i/Activity'
                                passing organization_details
                                columns site_id varchar2(100 char) path '/Activity/ActivityDescription/MonitoringLocationIdentifier',
                                        activity_identifier varchar2(4000 char) path '/Activity/ActivityDescription/ActivityIdentifier',
                                        activity_type_code varchar2(4000 char) path '/Activity/ActivityDescription/ActivityTypeCode',
                                        sample_media varchar2(30 char) path '/Activity/ActivityDescription/ActivityMediaName',
                                        activity_media_subdiv_name varchar2(4000 char) path '/Activity/ActivityDescription/ActivityMediaSubdivisionName',
                                        activity_start_date varchar2(10 char) path '/Activity/ActivityDescription/ActivityStartDate',
                                        activity_start_time varchar2(4000 char) path '/Activity/ActivityDescription/ActivityStartTime/Time',
                                        act_start_time_zone varchar2(4000 char) path '/Activity/ActivityDescription/ActivityStartTime/TimeZoneCode',
                                        activity_stop_date varchar2(4000 char) path '/Activity/ActivityDescription/ActivityEndDate',
                                        activity_stop_time varchar2(4000 char) path '/Activity/ActivityDescription/ActivityEndTime/Time',
                                        act_stop_time_zone varchar2(4000 char) path '/Activity/ActivityDescription/ActivityEndTime/TimeZoneCode',
                                        activity_depth varchar2(4000 char) path '/Activity/ActivityDescription/ActivityDepthHeightMeasure/MeasureValue',
                                        activity_depth_unit varchar2(4000 char) path '/Activity/ActivityDescription/ActivityDepthHeightMeasure/MeasureUnitCode',
                                        activity_depth_ref_point varchar2(4000 char) path '/Activity/ActivityDescription/ActivityDepthAltitudeReferencePointText',
                                        activity_upper_depth varchar2(4000 char) path '/Activity/ActivityDescription/ActivityTopDepthHeightMeasure/MeasureValue',
                                        activity_upper_depth_unit varchar2(4000 char) path '/Activity/ActivityDescription/ActivityTopDepthHeightMeasure/MeasureUnitCode',
                                        activity_lower_depth varchar2(4000 char) path '/Activity/ActivityDescription/ActivityBottomDepthHeightMeasure/MeasureValue',
                                        activity_lower_depth_unit varchar2(4000 char) path '/Activity/ActivityDescription/ActivityBottomDepthHeightMeasure/MeasureUnitCode',
                                        project_id varchar2(4000 char) path '/Activity/ActivityDescription/ProjectIdentifier',
                                        activity_conducting_org varchar2(4000 char) path '/Activity/ActivityDescription/ActivityConductingOrganizationText',
                                        activity_comment varchar2(4000 char) path '/Activity/ActivityDescription/ActivityCommentText',
                                        sample_aqfr_name varchar2(4000 char) path '/Activity/ActivityDescription/SampleAquifer',
                                        hydrologic_condition_name varchar2(4000 char) path '/Activity/ActivityDescription/HydrologicCondition',
                                        hydrologic_event_name varchar2(4000 char) path '/Activity/ActivityDescription/HydrologicEvent',
                                        sample_collect_method_id varchar2(4000 char) path '/Activity/SampleDescription/SampleCollectionMethod/MethodIdentifier',
                                        sample_collect_method_ctx varchar2(4000 char) path '/Activity/SampleDescription/SampleCollectionMethod/MethodIdentifierContext',
                                        sample_collect_method_name varchar2(4000 char) path '/Activity/SampleDescription/SampleCollectionMethod/MethodName',
                                        sample_collect_equip_name varchar2(4000 char) path '/Activity/SampleDescription/SampleCollectionEquipmentName',
                                        activity_details xmltype path '/Activity') activity
               ) activity,
               xmltable('for $j in /Activity return $j/Result'
                        passing activity_details
                        columns characteristic_name varchar2(32 char) path '/Result/ResultDescription/CharacteristicName',
                                result_detection_condition_tx varchar2(4000 char) path '/Result/ResultDescription/ResultDetectionConditionText',
                                sample_fraction_type varchar2(4000 char) path '/Result/ResultDescription/ResultSampleFractionText',
                                result_measure_value varchar2(4000 char) path '/Result/ResultDescription/ResultMeasure/ResultMeasureValue',
                                result_unit varchar2(4000 char) path '/Result/ResultDescription/ResultMeasure/MeasureUnitCode',
                                result_meas_qual_code varchar2(4000 char) path '/Result/ResultDescription/ResultMeasure/MeasureQualifierCode',
                                result_value_status varchar2(4000 char) path '/Result/ResultDescription/ResultStatusIdentifier',
                                statistic_type varchar2(4000 char) path '/Result/ResultDescription/StatisticalBaseCode',
                                result_value_type varchar2(4000 char) path '/Result/ResultDescription/ResultValueTypeName',
                                weight_basis_type varchar2(4000 char) path '/Result/ResultDescription/ResultWeightBasisText',
                                duration_basis varchar2(4000 char) path '/Result/ResultDescription/ResultTimeBasisText',
                                temperature_basis_level varchar2(4000 char) path '/Result/ResultDescription/ResultTemperatureBasisText',
                                particle_size varchar2(4000 char) path '/Result/ResultDescription/ResultParticleSizeBasisText',
                                precision varchar2(4000 char) path '/Result/ResultDescription/DataQuality/PrecisionValue',
                                result_comment varchar2(4000 char) path '/Result/ResultDescription/ResultCommentText',
                                result_depth_meas_value varchar2(4000 char) path '/Result/ResultDescription/ResultDepthHeightMeasure/MeasureValue',
                                result_depth_meas_unit_code varchar2(4000 char) path '/Result/ResultDescription/ResultDepthHeightMeasure/MeasureUnitCode',
                                result_depth_alt_ref_pt_txt varchar2(4000 char) path '/Result/ResultDescription/ResultDepthAltitudeReferencePointText',
                                sample_tissue_taxonomic_name varchar2(4000 char) path '/Result/BiologicalResultDescription/SubjectTaxonomicName',
                                sample_tissue_anatomy_name varchar2(4000 char) path '/Result/BiologicalResultDescription/SampleTissueAnatomyName',
                                analytical_procedure_id varchar2(4000 char) path '/Result/ResultAnalyticalMethod/MethodIdentifier',
                                analytical_procedure_source varchar2(4000 char) path '/Result/ResultAnalyticalMethod/MethodIdentifierContext',
                                analytical_method_name varchar2(4000 char) path '/Result/ResultAnalyticalMethod/MethodName',
                                analytical_method_citation varchar2(4000 char) path '/Result/ResultAnalyticalMethod/MethodDescriptionText',
                                lab_name varchar2(4000 char) path '/Result/ResultLabInformation/LaboratoryName',
                                analysis_date_time varchar2(4000 char) path '/Result/ResultLabInformation/AnalysisStartDate',
                                lab_remark varchar2(4000 char) path '/Result/ResultLabInformation/ResultLaboratoryCommentText',
                                detection_limit varchar2(4000 char) path '/Result/ResultLabInformation/ResultDetectionQuantitationLimit/DetectionQuantitationLimitMeasure/MeasureValue',
                                detection_limit_unit varchar2(4000 char) path '/Result/ResultLabInformation/ResultDetectionQuantitationLimit/DetectionQuantitationLimitMeasure/MeasureUnitCode',
                                detection_limit_desc varchar2(4000 char) path '/Result/ResultLabInformation/ResultDetectionQuantitationLimit/DetectionQuantitationLimitTypeName',
                                analysis_prep_date_tx varchar2(4000 char) path '/Result/LabSamplePreparation/PreparationStartDate')
       ) result
       join station_swap_stewards s
         on s.site_id = result.organization || '-' || result.site_id
       left join ars_stewards.char_name_to_type
         on result.characteristic_name = char_name_to_type.characteristic_name;

commit;

prompt building stewards activity indexes
exec etl_helper_activity.create_indexes('stewards');

prompt building stewards result indexes
exec etl_helper_result.create_indexes('stewards');

select 'transform result end time: ' || systimestamp from dual;
