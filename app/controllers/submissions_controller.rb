class SubmissionsController < ApplicationController
  layout :resolve_layout

  def index
    # @x_clinic_event_attest_methods = XClinicEventAttestMethod.group_by_group_id_and_clinic_id_and_event_id_and_fiscal_year_id_and_attestation_method_id_and_user_defined_fields(@selected_group.id, -1, @selected_event_id, @selected_attestation_requirement_fiscal_year_id, -1, ['-1'])
    @tin_summary_attestation_clinics = AttestationClinic.AttestationClinics_For_TIN_Summary_By_GroupID_And_EventID_And_UserDefinedFields(@selected_group.id, @selected_event_id, ['-1'], -1)

    @select_submission_statuses = SubmissionStatus.submission_status_for_select

    if request.post? and params[:save_flag]
      @tin_summary_attestation_clinics.each do |attestation_clinic|
        x_clinic_event = XAttestationClinicEvent.where(attestation_clinic_id: attestation_clinic.id, event_id: @selected_event_id).first
        if x_clinic_event
          x_clinic_event.submission_status_id = params[:ac_submission_status_id][x_clinic_event.id.to_s]
          x_clinic_event.save
        end

        attestation_clinic_methods = AttestationClinic.For_Submission_Home_By_AttestationClinic_FiscalYearID_StagingID_EventID(attestation_clinic.group_id, attestation_clinic.id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_event_id)
        attestation_clinic_methods.each do |attestation_clinic_method|
          if x_clinic_event and x_clinic_event.default_attestation_method
            attestation_method = AttestationMethod.find(attestation_clinic_method.am_id)
            if attestation_clinic_method.xceam_id and attestation_method.has_clinic_rollup?
              xceam = XClinicEventAttestMethod.find(attestation_clinic_method.xceam_id)
              xceam.aci_submit_flag = (!params[:xceam_aci_submit_flag].nil? and params[:xceam_aci_submit_flag][xceam.id.to_s] == '1')
              xceam.quality_submit_flag = (!params[:xceam_quality_submit_flag].nil? and params[:xceam_quality_submit_flag][xceam.id.to_s] == '1')
              xceam.cpia_submit_flag = (!params[:xceam_cpia_submit_flag].nil? and params[:xceam_cpia_submit_flag][xceam.id.to_s] == '1')
              xceam.resource_submit_flag = (!params[:xceam_resource_submit_flag].nil? and params[:xceam_resource_submit_flag][xceam.id.to_s] == '1')
              xceam.save

              if x_clinic_event.default_attestation_method_id == xceam.attestation_method_id
                x_clinic_event.aci_submit_flag = xceam.aci_submit_flag
                x_clinic_event.quality_submit_flag = xceam.quality_submit_flag
                x_clinic_event.cpia_submit_flag = xceam.cpia_submit_flag
                x_clinic_event.resource_submit_flag = xceam.resource_submit_flag
                x_clinic_event.save
              end
            end
          end
        end

        flash.now[:notice] = '<span class="yes">Updated Successfully!</span>'
      end
    end

    define_submission_subnav
  end

  def download_submission_file
    attestation_clinic_id = params[:ac_id].to_i
    event_id = params[:e_id].to_i
    attestation_method_id = params[:am_id].to_i
    if attestation_clinic_id > 0 and event_id > 0 and attestation_method_id > 0
      attestation_method = AttestationMethod.find(attestation_method_id)
      if attestation_method.has_clinic_rollup?
        attestation_clinic = AttestationClinic.find(attestation_clinic_id)
        file_name = "#{attestation_clinic.name}_qpp_submission_group"
        body_set = qpp_submission_object_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id, SubmissionMethod.find(SubmissionMethod.ehr_id).json_name_key)

        stream_json("#{file_name}.json", body_set)
      else
        download_zip_qpp_submission_departments(attestation_clinic_id, event_id, attestation_method_id)
      end
    end
  end

  def api_submit_submission_file
    attestation_clinic_id = params[:ac_id].to_i
    event_id = params[:e_id].to_i
    attestation_method_id = params[:am_id].to_i
    # x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    if attestation_clinic_id > 0 and event_id > 0 and attestation_method_id > 0
      attestation_method = AttestationMethod.find(attestation_method_id)
      if attestation_method.has_clinic_rollup?
        qpp_submission_api_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
      else
        # qpp_submission_api_departments(attestation_clinic_id, event_id, attestation_method_id)
      end
    end

    flash[:notice] = '<span class="yes">Submitted to API</span>'
    redirect_to :action => :index
  end

  def api_response_attestation_clinic_file_download
    attestation_clinic_id = params[:ac_id].to_i
    event_id = params[:e_id].to_i
    x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    if x_attestation_clinic_event.default_attestation_method and x_attestation_clinic_event.default_attestation_method.has_clinic_rollup?
      response = Response.find_by_attestation_clinic_id_and_attestation_requirement_fiscal_year_id(attestation_clinic_id, x_attestation_clinic_event.event.attestation_requirement_fiscal_year_id)
      body_set = JSON.parse(response.content.to_s)

      file_name = "#{x_attestation_clinic_event.attestation_clinic.name}_qpp_submission_group"
      stream_json("#{file_name}.json", body_set)
    end
  end

  def api_response_errors_download_csv_file
    attestation_clinic_id = params[:ac_id].to_i
    event_id = params[:e_id].to_i
    x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    if x_attestation_clinic_event.default_attestation_method and x_attestation_clinic_event.default_attestation_method.has_clinic_rollup?
      api_response_attestation_clinic_errors_download_csv_file(attestation_clinic_id, x_attestation_clinic_event.event.attestation_requirement_fiscal_year_id)
    elsif x_attestation_clinic_event.default_attestation_method
      # individual
    end
  end

  def api_response_attestation_clinic_errors_download_csv_file(attestation_clinic_id, attestation_requirement_fiscal_year_id)
    response = Response.find_by_attestation_clinic_id_and_attestation_requirement_fiscal_year_id(attestation_clinic_id, attestation_requirement_fiscal_year_id)
    if response and response.attestation_clinic.group_id == @selected_group_id
      response.response_errors
      base_file_name = response.attestation_clinic.name
      stream_csv("#{base_file_name}_api_submission_errors_#{@current_time.to_s}.csv") do |csv|
        # Title of report
        csv << "Title of Report: #{response.attestation_clinic.name} - api_submission_errors"
        csv << "Organization Name: #{response.attestation_clinic.group.name}"
        csv << ' '

        # header information
        header = []
        header << 'Type'
        header << 'Error Message'
        csv << header

        # detail information
        response.response_errors.each do |error|
          display_results = []
          display_results << error.error_type.to_s
          display_results << error.message.to_s

          csv << display_results
        end
      end
    end
  end

  private

  def define_submission_subnav
    @selected_side_nav_id = (params[:selected_side_nav_id] || session[:selected_side_nav_id]).to_i
    session[:selected_side_nav_id] = @selected_side_nav_id

    @selected_side_nav = [['TIN Submissions', 0, 'submission', 'index']]
    # @selected_side_nav += [['EC PI Results', 1, 'submission', 'ec_aci']]
    # @selected_side_nav += [['EC CQM Results', 2, 'submission', 'ec_cqm']]
    # @selected_side_nav += [['EC CPIA Results', 3, 'submission', 'ec_cpia']]
    # @selected_side_nav += [['EC Composite', 4, 'submission', 'ec_composite']]
    # @selected_side_nav += [['EC Financial %', 5, 'submission', 'ec_financial']]
    # @selected_side_nav += [['TIN PI Results', 6, 'submission', 'tin_aci']]
    # @selected_side_nav += [['TIN CQM Results', 7, 'submission', 'tin_cqm']]
    # @selected_side_nav += [['TIN CPIA Results', 8, 'submission', 'tin_cpia']]
    # @selected_side_nav += [['TIN Composite', 9, 'submission', 'tin_composite']]
    # @selected_side_nav += [['PI Measures', 10, 'submission', 'aci_measures']]
    # @selected_side_nav += [['CQM Measures', 11, 'submission', 'cqm_measures']]
    # @selected_side_nav += [['CPIA Measures', 12, 'submission', 'cpia_measures']]
  end
end
