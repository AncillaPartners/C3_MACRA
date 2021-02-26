class Response < ApplicationRecord
  has_many :response_errors, :dependent => :destroy
  belongs_to :attestation_requirement_fiscal_year
  belongs_to :attestation_clinic

  def process_cms_score_content
    begin
      import = JSON.parse(cms_score_content)
      cms_score = Response.get_cms_score(import)
      cms_category_scores = Response.get_cms_category_scores(import)

      record_for_cms_score_found = false
      event = Event.find_by_attestation_requirement_fiscal_year_id_and_active_and_status(attestation_requirement_fiscal_year_id, 1, 1)
      if npi.nil? or npi.strip.length == 0
        xace = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event.id)
        if xace and xace.default_attestation_method_id
          xceam = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(xace.attestation_clinic_id, xace.event_id, xace.default_attestation_method_id)
          if xceam
            xceam.cms_mips_composite_score = cms_score
            xceam.mips_composite_score = cms_score unless xceam.manual_composite_score_flag
            #   maybe auto set manual_composite_score_flag to false???
            xceam.cms_advancing_care_info = (cms_category_scores['aci'] || cms_category_scores['pi'])
            xceam.cms_quality = cms_category_scores['quality']
            # xceam.cms_resource_use = cms_category_scores['ru']
            xceam.cms_cpia = cms_category_scores['ia']
            xceam.save
            record_for_cms_score_found = true

            Response.save_all_cms_measure_scores(import, xceam)
          end
        end
      else
        attestation_clinic = AttestationClinic.find(attestation_clinic_id)
        department = Department.find_by_npi_and_group_id_and_active(npi, attestation_clinic.group_id, 1)
        if department
          mis = TempMipsIndivScoreboard.find_by_department_id_and_event_id_and_attestation_clinic_id(department.id, event.id, attestation_clinic.id)
          if mis
            mis.cms_mips_composite_score = cms_score
            #   maybe auto set manual_composite_score_flag to false???
            mis.mips_composite_score = cms_score unless mis.manual_composite_score_flag
            mis.cms_advancing_care_info = (cms_category_scores['aci'] || cms_category_scores['pi'])
            mis.cms_quality = cms_category_scores['quality']
            # xceam.cms_resource_use = cms_category_scores['ru']
            mis.cms_cpia = cms_category_scores['ia']
            mis.save
            record_for_cms_score_found = true

            Response.save_all_cms_measure_scores(import, mis)
          end
        end
      end

      unless record_for_cms_score_found
        QppResponseApiException.create({ :exception => 'No record found to apply CMS Score', :content => self.id })
      end

    rescue JSON::ParserError => e
      QppResponseApiException.create({ :exception => e.message, :content => self.id })
        # render :text => 'Data not recognized as JSON.', :status => '415 Unsupported Media Type'
        # return
    rescue => e
      QppResponseApiException.create({ :exception => e.message, :content => self.id })
      # render :text => 'Error while processing data.', :status => '500 Internal Server Error'
      # return
    end
  end

  def self.get_cms_score(import)
    if import['data']
      score_info = import['data']['score']['data']['score']
    else
      score_info = import['score']['data']['score']
    end

    cms_score = score_info['value'].to_f
  end

  def self.get_cms_category_scores(import)
    score_data = import['score']['data']['score']

    category_scores = {'aci' => nil, 'pi' => nil, 'quality' => nil, 'ru' => nil, 'ia' => nil}

    score_data['parts'].each do |category|
      if category['metadata'] and category['name']
        points = category['metadata']['unroundedScoreValue']
        denominator = category['metadata']['maxContribution']
        category_scores[category['name']] = (points.to_f / denominator.to_f) * 100
      end
    end

    return category_scores
  end

  def self.save_all_cms_measure_scores(import, entity)
    score_data = import['score']['data']['score']

    score_data['parts'].each do |category|
      case category['name']
        when 'aci', 'pi'
          Response.save_cms_aci_measure_scores(category, entity)
        when 'quality'
          Response.save_cms_quality_measure_scores(category, entity)
        when 'ru'
        when 'ia'
          Response.save_cms_cpia_measure_scores(category, entity)
      end
    end
  end

  def self.save_cms_aci_measure_scores(data, entity)
    score_data = nil
    if ['aci', 'pi'].include?(data['name'])
      score_data = data
    else
      data['score']['data']['score']['parts'].each do |category|
        if category['name'] and ['aci', 'pi'].include?(category['name'])
          score_data = category
        end
      end
    end

    if score_data
      if entity.class == TempMipsIndivScoreboard
        individual_type = true
        group_type = false
        department = entity.department
        group = department.group
        attestation_clinic_id = entity.attestation_clinic_id
        event_id = entity.event_id
      elsif entity.class == XClinicEventAttestMethod
        individual_type = false
        group_type = true
        attestation_clinic_id = entity.attestation_clinic_id
        attestation_method_id = entity.attestation_method_id
        event_id = entity.event_id
      end
      score_data['original']['parts'].each do |aci_parts|
        aci_parts['parts'].each do |aci_score_header|
          aci_score_header_value = aci_score_header['value']
          if aci_score_header['parts']
            aci_score_header['parts'].each do |measure|
              requirement_identifier = measure['name']
              if individual_type
                entity_req = XDepartmentCriterionRequirement.Department_Requirement_By_Group_DepartmentID_AttestationClinicID_EventID_RequirementIdentifier(group, department.id, attestation_clinic_id, event_id, requirement_identifier)
              elsif group_type
                entity_req = XClinicEventAttestGroupRequirement.group_requirement_by_attestation_clinic_id_and_attestation_method_id_and_event_id_and_requirement_identifier(attestation_clinic_id, attestation_method_id, event_id, requirement_identifier)
              end

              if entity_req
                entity_req.cms_submitted_flag = true
                entity_req.cms_aci_points = measure['value']
                entity_req.save
              end
            end
          end
        end
      end
    end
  end

  def self.save_cms_quality_measure_scores(data, entity)
    score_data = nil
    if data['name'] == 'quality'
      score_data = data
    else
      data['score']['data']['score']['parts'].each do |category|
        if category['name'] and category['name'] == 'quality'
          score_data = category
        end
      end
    end

    if score_data
      if entity.class == TempMipsIndivScoreboard
        individual_type = true
        group_type = false
        department = entity.department
        group = department.group
        attestation_clinic_id = entity.attestation_clinic_id
        event_id = entity.event_id
      elsif entity.class == XClinicEventAttestMethod
        individual_type = false
        group_type = true
        attestation_clinic_id = entity.attestation_clinic_id
        attestation_method_id = entity.attestation_method_id
        event_id = entity.event_id
      end
      score_data['original']['parts'].each do |cqm_parts|
        cqm_parts['parts'].each do |measure|
          requirement_identifier = measure['name']
          if individual_type
            entity_req = XDepartmentCriterionRequirement.Department_Requirement_By_Group_DepartmentID_AttestationClinicID_EventID_RequirementIdentifier(group, department.id, attestation_clinic_id, event_id, requirement_identifier)
          elsif group_type
            entity_req = XClinicEventAttestGroupRequirement.group_requirement_by_attestation_clinic_id_and_attestation_method_id_and_event_id_and_requirement_identifier(attestation_clinic_id, attestation_method_id, event_id, requirement_identifier)
          end

          if entity_req
            entity_req.cms_submitted_flag = true
            picked_text = 'Picked at '
            if measure['metadata']['messages']['measurementPicker'] and measure['metadata']['messages']['measurementPicker'].include?(picked_text)
              picked_order = measure['metadata']['messages']['measurementPicker'][picked_text.length..-1]
              begin
                picked_order = Integer(picked_order)
              rescue
                picked_order = nil
              end
              entity_req.cms_select_order = picked_order
            end
            case entity_req.requirement.metric_type_id.to_i
              when 3 # Non-Proportion
              when 4, 6 # Single-Performance Rate (Registry)
                entity_req.cms_total_decile_score = measure['value']
                entity_req.cms_decile_points = measure['metadata']['decileScore']
                entity_req.cms_performance_rate = measure['metadata']['performanceRate']
                entity_req.cms_priority_bonus_points = measure['metadata']['highPriorityBonus'] + measure['metadata']['outcomeOrPatientExperienceBonus']
                entity_req.cms_cehrt_bonus_points = measure['metadata']['endToEndBonus']
                entity_req.cms_numerator = measure['metadata']['performanceNumerator']
                entity_req.cms_denominator = measure['metadata']['performanceDenominator']
                entity_req.cms_eligible_population = measure['metadata']['eligiblePopulation']
                entity_req.cms_total_bonus_points = measure['metadata']['totalBonusPoints']
                entity_req.cms_total_measurement_points = measure['metadata']['totalMeasurementPoints']
              when 5, 7 # Multi-Performance Rate (Registry)
                case entity_req.requirement.cqm_overall_algorithm_id.to_i
                  when CqmOverallAlgorithm::SIMPLE_AVERAGE_ID
                  when CqmOverallAlgorithm::WEIGHTED_AVERAGE_ID
                  when CqmOverallAlgorithm::SUM_NUMERATORS_ID
                  when CqmOverallAlgorithm::OVERALL_STRATUM_ONLY_ID
                    entity_req.cms_total_decile_score = measure['value']
                    entity_req.cms_decile_points = measure['metadata']['decileScore']
                    entity_req.cms_performance_rate = measure['metadata']['performanceRate']
                    entity_req.cms_priority_bonus_points = measure['metadata']['highPriorityBonus'] + measure['metadata']['outcomeOrPatientExperienceBonus']
                    entity_req.cms_cehrt_bonus_points = measure['metadata']['endToEndBonus']
                    entity_req.cms_numerator = measure['metadata']['performanceNumerator']
                    entity_req.cms_denominator = measure['metadata']['performanceDenominator']
                    entity_req.cms_eligible_population = measure['metadata']['eligiblePopulation']
                    entity_req.cms_total_bonus_points = measure['metadata']['totalBonusPoints']
                    entity_req.cms_total_measurement_points = measure['metadata']['totalMeasurementPoints']
                end
            end
            entity_req.save
          end
        end
      end
    end
  end

  def self.save_cms_cpia_measure_scores(data, entity)
    score_data = nil
    if data['name'] == 'ia'
      score_data = data
    else
      data['score']['data']['score']['parts'].each do |category|
        if category['name'] and category['name'] == 'ia'
          score_data = category
        end
      end
    end

    if score_data
      if entity.class == TempMipsIndivScoreboard
        individual_type = true
        group_type = false
        department = entity.department
        group = department.group
        attestation_clinic_id = entity.attestation_clinic_id
        event_id = entity.event_id
      elsif entity.class == XClinicEventAttestMethod
        individual_type = false
        group_type = true
        attestation_clinic_id = entity.attestation_clinic_id
        attestation_method_id = entity.attestation_method_id
        event_id = entity.event_id
      end
      score_data['original']['parts'].each do |cpia_parts|
        cpia_parts['parts'].each do |measure|
          requirement_identifier = measure['name']
          if individual_type
            entity_req = XDepartmentCriterionRequirement.Department_Requirement_By_Group_DepartmentID_AttestationClinicID_EventID_RequirementIdentifier(group, department.id, attestation_clinic_id, event_id, requirement_identifier)
          elsif group_type
            entity_req = XClinicEventAttestGroupRequirement.group_requirement_by_attestation_clinic_id_and_attestation_method_id_and_event_id_and_requirement_identifier(attestation_clinic_id, attestation_method_id, event_id, requirement_identifier)
          end

          if entity_req
            entity_req.cms_submitted_flag = true
            entity_req.cms_cpia_points = measure['value']
            entity_req.save
          end
        end
      end
    end
  end
end
