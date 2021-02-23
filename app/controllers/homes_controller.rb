class HomesController < ApplicationController

  def show
    @user_messages = XUserMessage.messages_by_user_id(@user.id)
    @unread_message_count = @user_messages.select{|m| !m.read_flag}.size
    # @top_ten_cms_updates = CmsUpdate.CMS_Updates_By_Status_And_Active()

    @selected_side_nav_id = (params[:selected_side_nav_id] || session[:selected_side_nav_id] || 5).to_i
    session[:selected_side_nav_id] = @selected_side_nav_id

    @billing_info_fiscal_year = AttestationRequirementFiscalYear.find_by_mips_billing_active(1)
    @forecast_year_name = @billing_info_fiscal_year.mips_forecast_name

    increment = 0.1
    base = 0 - increment
    @scaling_factor_base_choices = Array.new(31){[base+=increment, base.to_s]}
    base = 0 - increment
    @scaling_factor_bonus_choices = Array.new(11){[base+=increment, base.to_s]}

    @scaling_factor_base_selected = (params[:scaling_factor_base] || session[:scaling_factor_base]).to_s
    @scaling_factor_bonus_selected = (params[:scaling_factor_bonus] || session[:scaling_factor_bonus]).to_s

    session[:scaling_factor_base] = @scaling_factor_base_selected
    session[:scaling_factor_bonus] = @scaling_factor_bonus_selected

    @delete_mode_user_types = [1]
    @delete_mode_security_levels = [1]

    @method_target_value_sets = []
    @assumption_method_target_value_sets = []

    group_directory = File.join('sftp', 'qrda_files', @selected_group.folder_label.to_s)
    if @selected_group.folder_label.to_s.length > 0 and File.directory?(group_directory)
      @has_qrda_3_directory = true
      @qrda_3_file_count = Dir[File.join(group_directory, '*')].count { |file| File.file?(file) }
      @has_qrda_3_import_delayed_job = JobHistory.find_all_by_group_id_and_job_type_and_job_status(@selected_group.id, 'Import QRDA 3 Files', ['Queued', 'Processing']).size > 0
      @import_qrda_3_files_button_text = (@has_qrda_3_import_delayed_job ? 'QRDA 3 Processing' : "Import #{@qrda_3_file_count} QRDA 3 Files")
      if @qrda_3_file_count > 0 and !@has_qrda_3_import_delayed_job
        @import_qrda_3_files_button_color = 'button_error'
      elsif @has_qrda_3_import_delayed_job or @qrda_3_file_count == 0
        @import_qrda_3_files_button_color = 'button_disable'
      end
    else
      @has_qrda_3_directory = false
    end

    @selected_department_owner_id = -1
    @accepted_security_levels = [4]
    @accepted_user_types = [1, 2]
    if @accepted_security_levels.include? @user.security_level_id and @accepted_user_types.include? @user.user_type_id
      @selected_department_owner_id = @user.id
    end
    @x_year_attestation_methods = XYearAttestationMethod.attestation_methods_by_group_and_clinic_and_event_and_year_and_department_owner(@selected_group.id, @selected_attestation_clinic_id_portal, @selected_event_id, @selected_attestation_requirement_fiscal_year_id, @selected_department_owner_id)
    @selected_attestation_methods = @x_year_attestation_methods.map {|xyam| [xyam.attestation_method.name, xyam.attestation_method_id]}
    if @selected_side_nav_id == 6 and params[:message_id] # Messages
      @show_message = true
      @message = Message.find(params[:message_id])
      XUserMessage.update_all({:read_flag => 1}, {:user_id => @user.id, :message_id => params[:message_id]})
      @user_messages = XUserMessage.messages_by_user_id(@user.id)
      @unread_message_count = @user_messages.select{|m| !m.read_flag}.size
    elsif @selected_side_nav_id == 5 # Reporting Entities
      @display = false

      @is_c3_admin = (@user.security_level_id == 1 and @user.user_type_id == 1)

      @attestation_methods = AttestationMethod.attestation_methods_by_fiscal_year_id(@selected_attestation_requirement_fiscal_year_id)
      @x_year_attestation_methods.each do |method|
        @method_target_value_sets += [XGroupYearAttestMethodTargetValueSet.find_or_create_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, method.attestation_method_id)]
      end
      @attestation_methods.each do |method|
        @assumption_method_target_value_sets += [XGroupYearAttestMethodTargetValueSet.find_or_create_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, method.id)]
      end

      @selected_user_defined_8_values = [['Not Set', '']] + AttestationClinic.group_user_defined_value_multiselect_by_group_id(@selected_group.id, 8)
      @multi_selected_user_defined_8_values = (params[:multi_selected_user_defined_8_values] || ['-1'])
    # elsif @selected_side_nav_id == 8 # TIN Comparisons
    #   apply_forecast = (params[:apply_forecast] || '-1').to_s
    #
    #   @scoring_methods = [['Current', 1], ['CMS', 2]]
    #   @selected_scoring_method = (params[:selected_scoring_method] || 1).to_i
    #   @scoring_method_name = ((@selected_scoring_method == 1) ? 'Current' : 'CMS')
    #
    #   @aco_attestation_methods = AttestationMethod.aco_attestation_methods_for_select
    #   @group_attestation_methods = AttestationMethod.group_attestation_methods_for_select
    #   @individual_attestation_methods = AttestationMethod.individual_attestation_methods_for_select
    #
    #   @attestation_clinics = []
    #   @all_clinic_results = {}
    #   @all_clinic_results[:total_ec_count] = 0
    #   @all_clinic_results[:total_base_medicare] = 0
    #   @all_clinic_results[:total_group_result] = 0
    #   @all_clinic_results[:total_individual_result] = 0
    #   @selectable_events = []
    #   @selected_aco_attestation_method_id = (params[:selected_aco_attestation_method_id] || -1).to_i
    #   @selected_group_attestation_method_id = (params[:selected_group_attestation_method_id] || -1).to_i
    #   @selected_individual_attestation_method_id = (params[:selected_individual_attestation_method_id] || -1).to_i
    #   if apply_forecast != '-1' and @selected_aco_attestation_method_id > 0 and @selected_group_attestation_method_id > 0 and (@selected_individual_attestation_method_id > 0 or (@selected_scoring_method == 2 and @individual_attestation_methods.size > 0))
    #
    #     @attestation_clinics = AttestationClinic.AttestationClinics_By_GroupID_and_EventID_and_YearID(@selected_group_id, @selected_event_id, @selected_attestation_requirement_fiscal_year_id)
    #
    #     aco_entity_type_id = @selected_aco_attestation_method_id
    #     group_entity_type_id = @selected_group_attestation_method_id
    #     individual_entity_type_id = ((@selected_individual_attestation_method_id > 0) ? @selected_individual_attestation_method_id : @individual_attestation_methods[0][1])
    #
    #     aco_attestation_method = AttestationMethod.find(aco_entity_type_id)
    #     aco_financial_method = XAttestationRequirementFiscalYearFinancialMethodType.find_by_attestation_requirement_fiscal_year_id_and_financial_method_type_id(@selected_attestation_requirement_fiscal_year_id, aco_attestation_method.financial_method_type_id)
    #     @aco_base_threshold = aco_financial_method.mips_financial_base_threshold_perc.to_f/100.0
    #     @aco_annual_adjust_perc = aco_financial_method.mips_base_adjustment_percent.to_f/100.0
    #     @aco_bonus_threshold = aco_financial_method.mips_financial_bonus_threshold_perc.to_f/100.0
    #     @aco_bonus_adjustment_perc_lower = aco_financial_method.mips_bonus_adjustment_percent_lower_limit.to_f/100.0
    #     @aco_bonus_adjustment_perc_upper = aco_financial_method.mips_bonus_adjustment_percent_upper_limit.to_f/100.0
    #     if @selected_event_id > 0
    #       @selectable_events = [Event.find(@selected_event_id)]
    #     else
    #       @selectable_events = Event.find_all_by_attestation_requirement_fiscal_year_id_and_group_type_id(@selected_attestation_requirement_fiscal_year_id, @selected_group.group_type_id)
    #     end
    #
    #     @all_clinic_results = all_clinic_forecast_scores(@attestation_clinics, @selected_event_id, @selected_attestation_requirement_fiscal_year_id, aco_entity_type_id, group_entity_type_id, individual_entity_type_id, @selected_scoring_method, @scaling_factor_base_selected, @scaling_factor_bonus_selected)
    #   end
    # elsif @selected_side_nav_id == 9 # MIPS ScoreCard
    #   @accepted_security_levels = [4]
    #   @accepted_user_types = [1, 2]
    #   if @accepted_security_levels.include? @user.security_level_id and @accepted_user_types.include? @user.user_type_id
    #     @selected_department_owner_id = @user.id
    #     @selected_department_owners = [[@user.first_name[0..0].to_s+'. '+@user.last_name, @user.id]]
    #     @multi_selected_department_owners = [@user.id.to_s]
    #   else
    #     @selected_department_owner_id = (params[:selected_department_owner_id] || -1).to_i
    #     @multi_selected_department_owners = ['-1']
    #     @selected_department_owners = XDepartmentCriterionStatus.department_owner_for_dash_board_select(@selected_group.id)
    #   end
    #   @csv_download_flag = (params[:csv_download_flag] || "0").to_i
    #
    #   @selected_requirement_id = (params[:selected_requirement_id] || -1).to_i
    #   @selected_requirements = XDepartmentCriterionStatus.multi_year_requirement_for_select(@selected_group, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id, @selected_event_id) #requirement_for_select(@selected_group.id)
    #
    #   @selected_requirement_type_id = (params[:selected_requirement_type_id] || "-1").to_i
    #   @selected_criteria = XDepartmentCriterionRequirement.criterion_for_select(@selected_group.id)
    #   @selected_requirement_types = XDepartmentCriterionRequirement.requirement_type_for_select(@selected_group.id)
    #
    #   @selected_departments = XDepartmentCriterionRequirement.department_for_select_for_attestation_clinic_by_department_owner(@selected_group.id, @selected_group.group_type_id, @selected_attestation_clinic_id_portal, @selected_department_owner_id)
    #
    #   @selected_department_id = (params[:selected_department_id] || -1).to_i
    #
    #   @selected_requirement_id = (params[:selected_requirement_id] || -1).to_i
    #   @selected_criterion_id = (params[:selected_criterion_id] || -1).to_i
    #   @exclude_terminated_eps = ((params[:exclude_terminated_eps] || 0).to_i == 1)
    #
    #
    #   @selected_user_defined_value_id_1 = (params[:selected_user_defined_value_id_1] || -1).to_i
    #   @selected_user_defined_value_id_2 = (params[:selected_user_defined_value_id_2] || -1).to_i
    #   @selected_user_defined_value_id_3 = (params[:selected_user_defined_value_id_3] || -1).to_i
    #   @selected_user_defined_value_id_5 = (params[:selected_user_defined_value_id_5] || -1).to_i
    #   @selected_user_defined_value_id_6 = (params[:selected_user_defined_value_id_6] || -1).to_i
    #   @selected_user_defined_value_id_7 = (params[:selected_user_defined_value_id_7] || -1).to_i
    #
    #   @selected_user_defined_1_values = Department.group_user_defined_value_for_dash_board_select(@selected_group.id, 1)
    #   @selected_user_defined_2_values = Department.group_user_defined_value_for_dash_board_select(@selected_group.id, 2)
    #   @selected_user_defined_3_values = Department.group_user_defined_value_for_dash_board_select(@selected_group.id, 3)
    #   @selected_user_defined_5_values = Department.group_user_defined_value_for_dash_board_select(@selected_group.id, 5)
    #   @selected_user_defined_6_values = Department.group_user_defined_value_for_dash_board_select(@selected_group.id, 6)
    #   @selected_user_defined_7_values = Department.group_user_defined_value_for_dash_board_select(@selected_group.id, 7)
    #
    #   @selected_technology_product_id = (params[:selected_technology_product_id] || -1).to_i
    #   @selected_compliance_date = (params[:selected_compliance_date] || -1).to_s
    #
    #   @multi_selected_criterion_statuses = (params[:multi_selected_criterion_statuses] || ['-1'])
    #   @selected_criterion_statuses_for_multi_select = XDepartmentCriterionRequirement.criterion_status_for_multi_select(@selected_group.id)
    #
    #   @selected_new_review_indicator_flag = (params[:selected_new_review_indicator_flag] || "-1").to_i
    #
    #   @selected_specialty_id = (params[:selected_specialty_id] || "-1").to_i
    #   @check_physician_accountability_flag = (params[:check_physician_accountability_flag] || false)
    #
    #   @selected_attestation_clinics = {}#AttestationClinic.AttestationClinics_By_GroupID_for_select_in_form(@selected_group.id)
    #   if params[:selected_attestation_clinic_id]
    #     @selected_attestation_clinic_id = params[:selected_attestation_clinic_id].to_i
    #     @selected_attestation_clinic_id_portal = params[:selected_attestation_clinic_id].to_i
    #   elsif session[:attestation_clinic_id_portal]
    #     @selected_attestation_clinic_id = session[:attestation_clinic_id_portal].to_i
    #     @selected_attestation_clinic_id_portal = session[:attestation_clinic_id_portal].to_i
    #   else
    #     @selected_attestation_clinic_id = -1
    #     session[:attestation_clinic_id_portal] = -1
    #     @selected_attestation_clinic_id_portal = -1
    #   end
    #
    #   @selected_attestation_clinic2s = {}
    #   @selected_attestation_clinic2s = AttestationClinic.AttestationClinic2s_By_GroupID_And_Assigned_Dept_for_select(@selected_group.id)
    #
    #   @selected_attestation_clinic2_id = (params[:selected_attestation_clinic2_id] || '-1')
    #
    #   @selected_clinics = Clinic.clinics_for_select_filter_by_group_id(@selected_group.id)
    #   @selected_clinic_id = (params[:selected_clinic_id] || -1).to_i
    #   @selected_clinic2s = Clinic.clinic2s_for_select_filter_by_group_id(@selected_group.id)
    #   @selected_clinic2_id = (params[:selected_clinic2_id] || -1).to_i
    #
    #   @selected_attestation_dates = AttestationRequirementSetDetail.group_attestation_dates_for_select(@selected_group, @selected_event_id) #Department.attestation_date_for_mass_maintenance_select(@selected_group.id)
    #
    #   @multi_selected_attestation_dates = (params[:multi_selected_attestation_dates] || ["-1"])
    #   @multi_selected_attestation_dates.each do |multi_selected_attestation_date|
    #     if multi_selected_attestation_date == "-1"
    #       @multi_selected_attestation_dates = ["-1"]
    #       break
    #     end
    #   end
    #
    #   @selected_department_owners.each do |dep_owner|
    #     if params[:selected_department_id].nil? and dep_owner[1].to_i == @user.id.to_i
    #       @selected_department_owner_id = @user.id
    #     end
    #   end
    #   @group_requirements_departments = XDepartmentCriterionRequirement.XGroupRequirements_And_Departments_By_Filters_v3b(@selected_department_id, @multi_selected_criterion_statuses, @selected_new_review_indicator_flag, @selected_group, @selected_compliance_date, @selected_technology_product_id, @selected_department_owner_id, @selected_requirement_id, @selected_user_defined_value_id_1, @selected_user_defined_value_id_2, @selected_user_defined_value_id_3, @selected_user_defined_value_id_5, @selected_user_defined_value_id_6, @selected_user_defined_value_id_7, @selected_specialty_id, @selected_criterion_id, @selected_requirement_type_id, @multi_selected_attestation_dates, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id, @selected_event_id, @selected_attestation_clinic_id_portal, @selected_attestation_clinic2_id, @selected_clinic_id, @selected_clinic2_id, @exclude_terminated_eps, params[:page])
    #   @group_requirements_departments_csv = XDepartmentCriterionRequirement.XGroupRequirements_And_Departments_By_Filters_v3b(@selected_department_id, @multi_selected_criterion_statuses, @selected_new_review_indicator_flag, @selected_group, @selected_compliance_date, @selected_technology_product_id, @selected_department_owner_id, @selected_requirement_id, @selected_user_defined_value_id_1, @selected_user_defined_value_id_2, @selected_user_defined_value_id_3, @selected_user_defined_value_id_5, @selected_user_defined_value_id_6, @selected_user_defined_value_id_7, @selected_specialty_id, @selected_criterion_id, @selected_requirement_type_id, @multi_selected_attestation_dates, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id, @selected_event_id, @selected_attestation_clinic_id_portal, @selected_attestation_clinic2_id, @selected_clinic_id, @selected_clinic2_id, @exclude_terminated_eps, 0)
    #
    #   # ScoreCard Report #
    #   @scorecard_physicians = XDepartmentCriterionRequirement.XGroupRequirements_And_Departments_By_Fiscal_Year(@selected_department_id, @multi_selected_criterion_statuses, @selected_new_review_indicator_flag, @selected_group, @selected_compliance_date, @selected_technology_product_id, @selected_department_owner_id, @selected_requirement_id, @selected_user_defined_value_id_1, @selected_user_defined_value_id_2, @selected_user_defined_value_id_3, @selected_user_defined_value_id_5, @selected_user_defined_value_id_6, @selected_user_defined_value_id_7, @selected_specialty_id, @selected_criterion_id, @selected_requirement_type_id, @multi_selected_attestation_dates, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id, @selected_event_id, @selected_attestation_clinic_id_portal, @selected_attestation_clinic2_id, @selected_clinic_id, @selected_clinic2_id, 0)
    #   if @csv_download_flag == 2
    #     download_csv_report_name = "ScoreCard" #"Physician Accountability"
    #     download_csv_file(@scorecard_physicians, download_csv_report_name, download_csv_report_name, @selected_group.name, @selected_group.id, @selected_group.group_type_id, @department_label, 13)
    #   elsif @csv_download_flag == 3
    #     respond_to do |format|
    #       format.html
    #       format.pdf { render :layout => false }
    #       @scorecard_requirements = Requirement.Requirements_By_Fiscal_Year(@selected_group, @selected_requirement_id, @selected_criterion_id, @selected_requirement_type_id, @selected_attestation_requirement_fiscal_year_id)
    #       table_width = 300
    #       if @selected_group.group_type_id.to_i == 3
    #         table_width += 350
    #       end
    #       @scorecard_requirements.each do |requirement|
    #         req_short_name = display_report_requirement_short_name(requirement.short_name, requirement.name)
    #         table_width += 50 + req_short_name.length*5
    #       end
    #       prawnto :filename => 'ScoreCard_' + @current_time.to_s + '.pdf', :prawn => { :page_size => [table_width, 1000] }
    #     end
    #   end
    #   ####################
    #
    #   # if @csv_download_flag == 1
    #   #   download_csv_report_name = "EP Accountability" #"Physician Accountability"
    #   #   download_csv_file(@group_requirements_departments_csv, download_csv_report_name, download_csv_report_name, @selected_group.name, @selected_group.id, @selected_group.group_type_id, @department_label, 7)
    #   # end
    #
    #   @display_advance_search_section = 1
    #   if @selected_specialty_id == -1 and @multi_selected_attestation_dates == ["-1"] and @selected_requirement_id == -1 and @selected_requirement_type_id == -1 and @selected_criterion_id == -1 and @selected_user_defined_value_id_1 == -1 and @selected_user_defined_value_id_2 == -1 and @selected_user_defined_value_id_3 == -1  and @selected_user_defined_value_id_5 == -1 and @selected_user_defined_value_id_6 == -1 and @selected_user_defined_value_id_7 == -1 and @check_physician_accountability_flag == false and @selected_attestation_clinic2_id == '-1'
    #     @display_advance_search_section = 0
    #   end
    #
    #   @multi_selected_criterion_statuses.each do |multi_selected_criterion_status|
    #     if multi_selected_criterion_status == "-1"
    #       @multi_selected_criterion_statuses = ["-1"]
    #       break
    #     end
    #   end
    elsif @selected_side_nav_id == 10 # TIN Summary
      # @tin_summary_attestation_clinics = AttestationClinic.AttestationClinics_For_TIN_Summary_By_GroupID_And_EventID(@selected_group.id, @selected_event_id)
      @selected_user_defined_8_values = [['Not Set', '']] + AttestationClinic.group_user_defined_value_multiselect_by_group_id(@selected_group.id, 8)
      @selected_meeting_status_values = [['No Status', 0]] + MeetingStatus.for_form_select

      @selected_meeting_statuses = MeetingStatus.for_form_select

      if @selected_event_id == -1
        @select_stage_message = 'Must select a stage.'
      end
    # elsif @selected_side_nav_id == 11 # Providers without PECOS
    #   @selected_pecos_clinic_id = (params[:selected_pecos_clinic_id] || -1).to_i
    #   @select_pecos_clinics = PecosClinic.PecosClinics_By_GroupID_And_Departments_Without_AttestationClinic_for_select(@selected_group.id)
    #   @selected_department_task_status_id = (params[:selected_department_task_status_id] || -1).to_i
    #   @select_department_task_statuses = DepartmentTaskStatus.filter_select_for_providers_without_ac(@selected_group.id)
    #
    #   @select_edit_department_task_statuses = DepartmentTaskStatus.for_form_select
    #   # @providers_without_pecos = Department.Group_Departments_Without_AttestationClinic_By_GroupID(@selected_group.id)
    # elsif @selected_side_nav_id == 12 # ACO Peer Review (Financial Peer Review)
    #   # @tin_summary_attestation_clinics = AttestationClinic.AttestationClinics_For_TIN_Summary_By_GroupID_And_EventID(@selected_group.id, @selected_event_id)
    #   @selected_user_defined_8_values = [['Not Set', '']] + AttestationClinic.group_user_defined_value_multiselect_by_group_id(@selected_group.id, 8)
    #   @multi_selected_user_defined_8_values = (params[:multi_selected_user_defined_8_values] || ['-1'])
    #
    #   @selected_attestation_methods = [['ALL', -1]] + @selected_attestation_methods
    #   default_aco_x_year_attestation_method = @x_year_attestation_methods.select{|xyam| xyam.attestation_method.has_group_rollup?}.first
    #
    #   @hide_aci_high = (params[:hide_aci_high])
    #   @hide_cqm_high = (params[:hide_cqm_high])
    #   @hide_cpia_high = (params[:hide_cpia_high])
    #
    #   params[:selected_page_version_id] = (params[:selected_page_version_id] || default_aco_x_year_attestation_method.attestation_method_id) if default_aco_x_year_attestation_method
    #   if @selected_event_id == -1
    #     @select_stage_message = 'Must select a stage.'
    #   end
    # elsif @selected_side_nav_id == 13 # QPP Mismatch
    #   @selected_department_task_status_id = (params[:selected_department_task_status_id] || -1).to_i
    #   @select_department_task_statuses = DepartmentTaskStatus.filter_select_for_providers_by_group_and_ac(@selected_group.id, @selected_attestation_clinic_id_portal)
    #
    #   @select_edit_department_task_statuses = DepartmentTaskStatus.for_form_select
    # elsif @selected_side_nav_id == 14 # ECs Other Reporting Entity
    #   @req_set_details = AttestationRequirementSetDetail.AttestationMethod_Differ_from_AC_Default_By_GroupID_EventID_AttestationClinicID(@selected_group.id, @selected_event_id, @selected_attestation_clinic_id_portal)
    #   if @selected_event_id == -1
    #     @select_stage_message = 'Must select a stage.'
    #   end
    else
      @selected_low_volume = (params[:low_volume] || 0).to_i

      # @x_year_attestation_methods = XYearAttestationMethod.attestation_methods_by_year(@selected_attestation_requirement_fiscal_year_id)
      # @attestation_methods = AttestationMethod.attestation_methods_by_fiscal_year_id(@selected_attestation_requirement_fiscal_year_id)

      @departments_no_entity_type = []
      # @selected_attestation_methods = @x_year_attestation_methods.map {|xyam| [xyam.attestation_method.name, xyam.attestation_method_id]}
      if @selected_side_nav_id == 0 # Financial Summary
        @selected_user_defined_8_values = [['Not Set', '']] + AttestationClinic.group_user_defined_value_multiselect_by_group_id(@selected_group.id, 8)
        @multi_selected_user_defined_8_values = (params[:multi_selected_user_defined_8_values] || ['-1'])

        @departments_no_entity_type = Department.Group_Departments_By_GroupID_ClinicID_EventID_XYearAttestationMethodID_UserDefinedFields_DepartmentOwnerID_BillingYear(@selected_group.id, @selected_attestation_clinic_id_portal, @selected_event_id, nil, @multi_selected_user_defined_8_values, @selected_department_owner_id, @billing_info_fiscal_year.id, @selected_attestation_requirement_fiscal_year_id)

        if @departments_no_entity_type.size > 0;
          @selected_attestation_methods << ['Not Set', 0]
        end
      elsif @selected_side_nav_id == 7 # Low Volume Confirmation / QPP Data Confirmation
        @selected_low_volume = (params[:low_volume_only] || -1).to_i

        @selected_confirmed_options = [['ALL', -1], ['Yes', 1], ['No', 0]]
        @selected_confirmed = (params[:selected_confirmed] || -1).to_i

        @selected_x_year_attestation_methods = XYearAttestationMethod.attestation_method_select_by_year(@selected_attestation_requirement_fiscal_year_id)
      end
      # @selected_page_version_id = (params[:selected_page_version_id] || params[:selected_page_version_id_persist] || @x_year_attestation_methods.first.attestation_method_id).to_i if @x_year_attestation_methods.first

      #################################################################
      # if session[:selected_page_version_id].nil? or !@selected_attestation_methods.any?{|method| method[1] == session[:selected_page_version_id]}
      #   session[:selected_page_version_id] = (@selected_attestation_methods.first.attestation_method_id).to_i if @selected_attestation_methods.first
      # end
      # @default_page_version_id = session[:selected_page_version_id]
      # @selected_page_version_id = (params[:selected_page_version_id] || @default_page_version_id).to_i if @selected_attestation_methods.first
      # session[:selected_page_version_id] = @selected_page_version_id
      #################################################################

      # @attestation_clinics = AttestationClinic.AttestationClinics_For_Scoreboard_By_GroupID_And_EventID(@selected_group.id, @selected_event_id, @billing_info_fiscal_year.id)
      # @departments = Department.Group_Departments_By_ClinicID_EventID_For_Scoreboard(@selected_group.id, @selected_attestation_clinic_id_portal, @selected_event_id, @billing_info_fiscal_year.id, 1)
    end
    session[:selected_page_version_id_persist] = params[:selected_page_version_id_persist].to_i if params[:selected_page_version_id_persist]
    if session[:selected_page_version_id_persist].nil? or !@selected_attestation_methods.any?{|method| method[1] == session[:selected_page_version_id_persist]}
      session[:selected_page_version_id_persist] = (@selected_attestation_methods.first[1]).to_i if @selected_attestation_methods.first
    end
    @default_page_version_id = session[:selected_page_version_id_persist]
    @selected_page_version_id = (params[:selected_page_version_id] || @default_page_version_id).to_i if @selected_attestation_methods.first
    session[:selected_page_version_id_persist] = @selected_page_version_id

    # @selected_side_nav_id == 10 # TIN Summary
    @tin_summary_multi_selected_user_defined_8_values = (params[:tin_summary_multi_selected_user_defined_8_values] || ['-1'])
    @tin_summary_selected_meeting_status_id = (params[:tin_summary_selected_meeting_status_id] || -1).to_i
    if @selected_event_id == -1
      @tin_summary_attestation_clinics = []
    else
      @tin_summary_attestation_clinics = AttestationClinic.AttestationClinics_For_TIN_Summary_By_GroupID_And_EventID_And_UserDefinedFields(@selected_group.id, @selected_event_id, @tin_summary_multi_selected_user_defined_8_values, @tin_summary_selected_meeting_status_id)
    end

    # @selected_side_nav_id == 11 # Providers without PECOS
    @providers_without_pecos = Department.Group_Departments_Without_AttestationClinic_By_GroupID_And_PecosClinic_And_DepartmentTaskStatus(@selected_group.id, @selected_pecos_clinic_id, @selected_department_task_status_id, @billing_info_fiscal_year.id)

    # @selected_side_nav_id == 13 # QPP Mismatch
    @qpp_mismatch_providers = Department.Group_Departments_With_Task_Status_By_GroupID_AttestationClinicID_DepartmentTaskStatusID(@selected_group.id, @selected_attestation_clinic_id_portal, @selected_department_task_status_id)

    if @selected_side_nav_id == 12 and @selected_page_version_id > 0 # ACO Peer Review (Financial Peer Review)
      @selected_attestation_method = AttestationMethod.find(@selected_page_version_id)
      if @selected_attestation_method.has_group_rollup?
        @x_group_year_attest_method = XGroupYearAttestMethod.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @selected_page_version_id)
        @aco_target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @selected_page_version_id)

        @aco_x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @selected_page_version_id)
      end
    end

    if request.post?
      accepted_security_levels = [1, 2, 3, 6]
      accepted_user_types = [1]
      if accepted_security_levels.include? @user.security_level_id and accepted_user_types.include? @user.user_type_id
        @save_save_macra_financial_summary_flag = (params[:save_macra_financial_summary_flag] || '-1').to_s
        @financial_summary_csv_download_flag = (params[:financial_summary_csv_download_flag] || '-1').to_s
        @aco_peer_review_csv_download_flag = (params[:aco_peer_review_csv_download_flag] || '-1').to_s
        @save_providers_without_pecos_flag = (params[:save_providers_without_pecos_flag] || '-1').to_s
        @save_qpp_mismatch_flag = (params[:save_qpp_mismatch_flag] || '-1').to_s
        @providers_without_ac_csv_download_flag = (params[:providers_without_ac_csv_download_flag] || '-1').to_s
        @import_qrda_3_files = (params[:import_qrda_3_files] || '-1').to_s
        save_scaling_factors_flag = (params[:save_scaling_factors_flag] || '-1').to_s
        save_low_volume_confirms = (params[:save_low_volume_confirms] || '-1').to_s
        remove_ac_from_department = (params[:remove_ac_from_department] || '-1').to_s
        save_use_manual_fields_flags = (params[:save_use_manual_fields_flags] || '-1').to_s
        if @save_save_macra_financial_summary_flag != '-1'
          @assumption_method_target_value_sets.each do |target_set|
            target_set.update_attribute(:advancing_care_info, params["aci_target_#{target_set.id}"])
            target_set.update_attribute(:quality, params["cqm_target_#{target_set.id}"])
            target_set.update_attribute(:resource_use, params["resource_target_#{target_set.id}"])
            target_set.update_attribute(:cpia, params["cpia_target_#{target_set.id}"])
          end
          @method_target_value_sets = []
          @x_year_attestation_methods.each do |method|
            @method_target_value_sets += [XGroupYearAttestMethodTargetValueSet.find_or_create_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, method.attestation_method_id)]
          end
          @save_message = "<span class='yes'>Target Values saved!</span>"
          @display = true
        elsif @save_providers_without_pecos_flag != '-1'
          @providers_without_pecos.each do |department|
            if params[:d_department_task_status][department.id.to_s] != nil
              department.update_attribute(:department_task_status_id, params[:d_department_task_status][department.id.to_s])
            end
          end

          @select_pecos_clinics = PecosClinic.PecosClinics_By_GroupID_And_Departments_Without_AttestationClinic_for_select(@selected_group.id)
          @select_department_task_statuses = DepartmentTaskStatus.filter_select_for_providers_without_ac(@selected_group.id)
        elsif @save_qpp_mismatch_flag != '-1'
          @qpp_mismatch_providers.each do |department|
            if params[:d_department_task_status][department.id.to_s] != nil
              department.update_attribute(:department_task_status_id, params[:d_department_task_status][department.id.to_s])
            end
          end
        elsif save_scaling_factors_flag != '-1'
          x_group_year = XGroupYear.find_by_group_id_and_attestation_requirement_fiscal_year_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id)
          x_group_year.scaling_factor_base = params[:scaling_factor_base]
          x_group_year.scaling_factor_bonus = params[:scaling_factor_bonus]
          x_group_year.save
          @scaling_factor_values_updated = "<span class='yes'>Scaling Factor Values saved!</span>"
        elsif @financial_summary_csv_download_flag != '-1' and @selected_page_version_id > 0
          financial_summary_download_csv_file('financial_summary', 'Financial Summary', @selected_group.name)
        elsif @aco_peer_review_csv_download_flag != '-1'
          aco_peer_review_download_csv_file('financial_peer_review', 'Financial Peer Review', @selected_group.name, @hide_aci_high, @hide_cqm_high, @hide_cpia_high)
        elsif @providers_without_ac_csv_download_flag != '-1'
          providers_without_ac_download_csv_file('provides_without_ac', 'Providers Without AC', @selected_group.name, @providers_without_pecos)
        elsif @import_qrda_3_files != '-1' and !@has_qrda_3_import_delayed_job and @qrda_3_file_count > 0 and [1].include? @user.user_type_id and [1].include? @user.security_level_id
          begin
            if params[:end_date_month_override].to_i > 0 or params[:end_date_day_override].to_i > 0
              # Test to see if real date (including leap year)
              #   QRDA3 import handles leap year day Feb 29 and makes it Feb 28 for non-leap years.
              Date.new(2016, params[:end_date_month_override].to_i, params[:end_date_day_override].to_i)
            end
            aci_to_pi_override = !params[:aci_to_pi_override].nil?
            @has_qrda_3_import_delayed_job = true
            @import_qrda_3_files_button_text = 'QRDA 3 Processing'
            @import_qrda_3_files_button_color = 'button_disable'

            job_history = JobHistory.create(:group_id => @selected_group_id, :user_id => @user.id, :job_status => 'Queued',
                                            :job_type => 'Import QRDA 3 Files', :request_at => @current_time.to_s)
            Delayed::Job.enqueue ImportQrda3FilesJob.new(job_history.id, @selected_group_id, params[:end_date_month_override], params[:end_date_day_override], aci_to_pi_override)
            flash.now[:notice] = "<span class='yes'>Import QRDA 3 Files queued for processing</span>"
          rescue ArgumentError => e
            flash.now[:notice] = "<span class='no'>Import QRDA 3 Files - Invalid Date</span>"
          end
        elsif save_low_volume_confirms != '-1'
          if params[:attestation_requirement_set_details].size > 0
            params[:attestation_requirement_set_details].each do |arsd_id|
              low_volume_flag = params["low_volume_flag_#{arsd_id}"].to_i
              low_volume_confirmed_flag = ((params["confirmed_#{arsd_id}"] == '0' or params["confirmed_#{arsd_id}"].nil?) ? 0 : 1)
              x_year_attestation_method_id = params["x_year_attestation_method_id_#{arsd_id}"].to_i

              AttestationRequirementSetDetail.update(arsd_id,
                                                     :low_volume_flag => low_volume_flag,
                                                     :low_volume_confirmed_flag => low_volume_confirmed_flag,
                                                     :x_year_attestation_method_id => x_year_attestation_method_id)
            end
            flash.now[:notice] = "<span class='yes'>QPP Data Confirms saved!</span>"
          end
        elsif remove_ac_from_department != '-1'
          if @delete_mode_user_types.include? @user.user_type_id and @delete_mode_security_levels.include? @user.security_level_id
            if params[:arsds_to_delete_by_ac].size > 0
              fiscal_year = AttestationRequirementFiscalYear.find(@selected_attestation_requirement_fiscal_year_id)
              selected_event_name = (@selected_event_id > 0 ? Event.find(@selected_event_id).name : fiscal_year.name)
              params[:arsds_to_delete_by_ac].each do |ac_and_arsds|
                attestation_clinic_id = ac_and_arsds[0].to_i
                arsds_to_delete = ac_and_arsds[1]
                arsds_that_exist = []
                arsds_to_delete.each do |arsd_to_delete|
                  attestation_requirement_set_detail = AttestationRequirementSetDetail.find_by_id(arsd_to_delete)
                  unless attestation_requirement_set_detail.nil?
                    arsds_that_exist << arsd_to_delete
                  end
                end
                attestation_clinic = AttestationClinic.find(attestation_clinic_id)
                job_history = JobHistory.create(:group_id => attestation_clinic.group_id, :user_id => @user.id, :job_status => 'Queued',
                                                :job_type => "QPP Data Confirm Remove marked ECs from Attestation Clinic - #{attestation_clinic.name} - #{selected_event_name}", :request_at => @current_time.to_s)
                Delayed::Job.enqueue MassRemoveDepartmentsFromAttestationClinicJob.new(job_history.id, attestation_clinic.group_id, attestation_clinic_id, arsds_that_exist)
              end

              @current_batch_jobs = JobHistory.find_all_by_group_id_and_job_status(@selected_group.id, ['Queued', 'Processing']).size
              flash.now[:notice] = "<span class='yes'>QPP Data Confirm Remove marked ECs from Attestation Clinics queued for processing</span>"
            end
          end
        elsif save_use_manual_fields_flags != '-1' and (params[:manual_percent_flag] or params[:aci_use_manual_fields_flag] or params[:quality_use_manual_fields_flag])
          params[:manual_percent_flag].each do |x_attestation_clinic_event_id, value|
            x_attestation_clinic_event = XAttestationClinicEvent.update(x_attestation_clinic_event_id, :manual_percent_flag => (value.to_i == 1))

            x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(x_attestation_clinic_event.attestation_clinic_id, x_attestation_clinic_event.event_id, x_attestation_clinic_event.default_attestation_method_id)
            if x_clinic_event_attest_method
              x_clinic_event_attest_method.manual_percent_flag = x_attestation_clinic_event.manual_percent_flag
              x_clinic_event_attest_method.save
            end
          end
          params[:aci_use_manual_fields_flag].each do |x_attestation_clinic_event_id, value|
            x_attestation_clinic_event = XAttestationClinicEvent.update(x_attestation_clinic_event_id, :aci_use_manual_fields_flag => (value.to_i == 1))

            x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(x_attestation_clinic_event.attestation_clinic_id, x_attestation_clinic_event.event_id, x_attestation_clinic_event.default_attestation_method_id)
            if x_clinic_event_attest_method
              x_clinic_event_attest_method.aci_use_manual_fields_flag = x_attestation_clinic_event.aci_use_manual_fields_flag
              x_clinic_event_attest_method.save
            end
          end
          params[:quality_use_manual_fields_flag].each do |x_attestation_clinic_event_id, value|
            x_attestation_clinic_event = XAttestationClinicEvent.update(x_attestation_clinic_event_id, :quality_use_manual_fields_flag => (value.to_i == 1))

            x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(x_attestation_clinic_event.attestation_clinic_id, x_attestation_clinic_event.event_id, x_attestation_clinic_event.default_attestation_method_id)
            if x_clinic_event_attest_method
              x_clinic_event_attest_method.quality_use_manual_fields_flag = x_attestation_clinic_event.quality_use_manual_fields_flag
              x_clinic_event_attest_method.save
            end
          end
          params[:meeting_status_id].each do |x_attestation_clinic_event_id, value|
            XAttestationClinicEvent.update(x_attestation_clinic_event_id, :meeting_status_id => value)
          end
        end
      end
    end

    define_home_subnav
  end

  def query_pecos_for_attestation_clinics
    accepted_user_types_for_actions = [1]
    accepted_security_levels_for_actions = [1, 2, 3, 6]
    begin
      department = Department.find params[:department_id].to_i
      if department.group_id == @selected_group_id and department.npi and department.npi.strip.length > 0 and accepted_user_types_for_actions.include? @user.user_type_id and accepted_security_levels_for_actions.include? @user.security_level_id
        update_clinics_from_pecos_api_for_department(department.id, @selected_event_id)

        # flash[:notice] = '<span class="yes">Added PECOS</span>'
        # redirect_to :controller => :department, :action => :show, :id => department
        # redirect_to :action => :index, :selected_side_nav_id => 11

        department = Department.find params[:department_id].to_i
        pecos_updated_at = ((department.pecos_updated_at) ? short_datetime_view(department.pecos_updated_at.in_time_zone('Central Time (US & Canada)')) : '')
        pecos_clinics = department.pecos_clinics_ordered.map {|pecos_clinic|
          [pecos_clinic.name, pecos_clinic.id]
        }
        render :json => {:message => 'Added PECOS', :pecos_updated_at => pecos_updated_at, :pecos_clinics => pecos_clinics}
      else
        # flash[:notice] = '<span class="no">Not allowed to Add PECOS Clinics</span>'
        # redirect_to :action => :index, :selected_side_nav_id => 11
        render :json => {:message => 'Not allowed to Add PECOS Clinics'}
      end
    rescue ActiveRecord::RecordNotFound
      # flash[:notice] = "<span class='no'>Invalid Department ID</span>"
      # redirect_to :action => :index, :selected_side_nav_id => 11
      render :json => {:message => 'Invalid Department ID'}
    end
  end

  def what_if_popup
    @selected_department_owner_id = -1
    accepted_security_levels = [4]
    accepted_user_types = [1, 2]
    if accepted_security_levels.include? @user.security_level_id and accepted_user_types.include? @user.user_type_id
      @selected_department_owner_id = @user.id
    end
    if @selected_attestation_clinic_id_portal < 0
      @selected_attestation_clinic_id_portal = @selected_attestation_clinics_portal.first[1]
    end

    @is_c3_admin = (@user.security_level_id == 1 and @user.user_type_id == 1)

    @selected_attestation_method_id = (params[:selected_attestation_method_id] || 1).to_i
    @selected_if_attestation_method_id = (params[:selected_if_attestation_method_id] || -1).to_i
    if @selected_if_attestation_method_id > 0
      @if_attestation_method_id = @selected_if_attestation_method_id
    else
      @if_attestation_method_id = @selected_attestation_method_id
    end
    current_if_attestation_method_id = (params[:current_if_attestation_method_id] || -1).to_i
    @selected_if_submission_method_id = (params[:selected_if_submission_method_id] || -1).to_i

    @billing_info_fiscal_year = AttestationRequirementFiscalYear.find_by_mips_billing_active(1)


    @scaling_factor_base_selected = session[:scaling_factor_base]
    @scaling_factor_bonus_selected = session[:scaling_factor_bonus]


    @method_target_value_sets = []

    @x_year_attestation_methods = XYearAttestationMethod.what_if_attestation_methods_by_year(@selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
    @selected_attestation_methods = @x_year_attestation_methods.map {|xyam| [xyam.attestation_method.name, xyam.attestation_method_id]}

    @selected_submission_methods = SubmissionMethod.for_select

    @target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
    @x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @target_set.attestation_method_id)

    if @x_year_attestation_method.default_submission_method
      @selected_submission_methods.each do |sm|
        if sm[1] == @x_year_attestation_method.default_submission_method_id
          sm[0] += ' *'
        end
      end
    end

    unless @x_year_attestation_method.attestation_method.changeable_flag
      @if_attestation_method_id = @x_year_attestation_method.attestation_method_id
    end
    if @if_attestation_method_id > 0
      @what_if_target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @if_attestation_method_id)
      @if_x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @what_if_target_set.attestation_method_id)

      if @selected_if_attestation_method_id > 0 and current_if_attestation_method_id != @selected_if_attestation_method_id and @if_x_year_attestation_method.default_submission_method and @selected_if_submission_method_id < 0 and @x_year_attestation_method.attestation_method.changeable_flag
        @selected_if_submission_method_id = @if_x_year_attestation_method.default_submission_method_id
      end
    end


    if request.post?
      accepted_security_levels = [1, 2, 3, 6]
      accepted_user_types = [1]
      if accepted_security_levels.include? @user.security_level_id and accepted_user_types.include? @user.user_type_id
        @convert = (params[:convert] || -1).to_s
        if @convert != '-1' and (@if_attestation_method_id > 0 or @selected_if_submission_method_id > 0)
          was_group = @x_year_attestation_method.attestation_method.has_clinic_rollup?
          new_group = @if_x_year_attestation_method.attestation_method.has_clinic_rollup?
          events_changed = Set.new
          @department_attestation_requirement_set_details = AttestationRequirementSetDetail.Departments_AttestationRequirementSetDetails_By_EPType_Specialties_UserDefinedFields_TechnologyProduct_DepartmentOwners_CMSProgramType_AttestationDates_AttestationStatus_FiscalYearID_StagingID_RequirementTypeID_EventID_AttestationClinicID(@selected_group, -1, [-1], [-1], [-1], [-1], [-1], [-1], [-1], -1, [-1], -1, [-1], [-1], @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id, -1, -1, @selected_event_id, [@selected_attestation_clinic_id_portal], -1, nil, -1, [-1], @x_year_attestation_method.id, -1, -1, -1)
          @department_attestation_requirement_set_details.each do |arsd|
            if @selected_if_submission_method_id > 0
              arsd.submission_method_id = @selected_if_submission_method_id
            elsif @selected_if_submission_method_id == -1 and arsd.submission_method.nil?
              arsd.submission_method_id = @selected_submission_methods.first[1].to_i
            end
            arsd.x_year_attestation_method_id = @if_x_year_attestation_method.id

            x_event_attestation_method = XEventAttestationMethod.find_by_event_id_and_attestation_method_id(arsd.event_id, @if_x_year_attestation_method.attestation_method_id)
            if x_event_attestation_method.default_cqm_selection_template
              cqm_selection_template_id = x_event_attestation_method.default_cqm_selection_template_id
            else
              cqm_selection_template_id = nil
            end
            arsd.cqm_selection_template_id = cqm_selection_template_id
            arsd.cqm_manual_override_flag = false
            arsd.save
            events_changed.add(arsd.event)

            calculate_department_macra_scores(arsd.x_department_attestation_requirement_set_details.first.department, arsd.event)
          end
          if @selected_attestation_clinic_id_portal > 0
            selected_clinic = AttestationClinic.find(@selected_attestation_clinic_id_portal)
            selected_clinic.default_attestation_method_id = @if_attestation_method_id
            selected_clinic.save
            events_changed.each do |event_changed|
              if was_group and @x_year_attestation_method.id != @if_x_year_attestation_method.id
                calculate_clinic_macra_scores(selected_clinic, event_changed, @x_year_attestation_method.attestation_method_id)
              end
              if new_group
                create_requirements = false
                xceam = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(selected_clinic.id, event_changed.id, @if_x_year_attestation_method.attestation_method_id)
                if xceam.nil?
                  xceam = XClinicEventAttestMethod.new
                  xceam.attestation_clinic_id = selected_clinic.id
                  xceam.event_id = event_changed.id
                  xceam.attestation_method_id = @if_x_year_attestation_method.attestation_method_id

                  create_requirements = true
                end
                if @selected_if_submission_method_id > 0
                  xceam.submission_method_id = @selected_if_submission_method_id
                elsif @selected_if_submission_method_id == -1 and xceam.submission_method_id.nil?
                  xceam.submission_method_id = @selected_submission_methods.first[1].to_i
                end

                x_event_attestation_method = XEventAttestationMethod.find_by_event_id_and_attestation_method_id(event_changed.id, xceam.attestation_method_id)
                if x_event_attestation_method.default_cqm_selection_template
                  cqm_selection_template_id = x_event_attestation_method.default_cqm_selection_template_id
                else
                  cqm_selection_template_id = nil
                end
                xceam.cqm_selection_template_id = cqm_selection_template_id
                xceam.cqm_manual_override_flag = 0

                xceam.save

                calculate_clinic_macra_scores(selected_clinic, event_changed, @if_x_year_attestation_method.attestation_method_id, create_requirements)
              end
            end
            if was_group and @x_year_attestation_method.id != @if_x_year_attestation_method.id
              calculate_group_aco_score(selected_clinic.group, @selected_attestation_requirement_fiscal_year, @x_year_attestation_method.attestation_method_id)
            end
            if new_group
              calculate_group_aco_score(selected_clinic.group, @selected_attestation_requirement_fiscal_year, @if_x_year_attestation_method.attestation_method_id)
            end
          end

          @selected_attestation_method_id = @if_attestation_method_id
          @target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
          @x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @target_set.attestation_method_id)

          @x_year_attestation_methods = XYearAttestationMethod.what_if_attestation_methods_by_year(@selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
          @selected_attestation_methods = @x_year_attestation_methods.map {|xyam| [xyam.attestation_method.name, xyam.attestation_method_id]}

          @selected_if_attestation_method_id = -1
          @what_if_target_set = nil
          @if_x_year_attestation_method = nil
          @selected_if_submission_method_id = -1

          @convert_message = "<span class='yes'>Physicians converted</span>"
        end
      end
    end

    render :layout => :resolve_pop_up_layout
  end

  def what_if_submission_popup
    @selected_department_owner_id = -1
    accepted_security_levels = [4]
    accepted_user_types = [1, 2]
    if accepted_security_levels.include? @user.security_level_id and accepted_user_types.include? @user.user_type_id
      @selected_department_owner_id = @user.id
    end

    @selected_attestation_method_id = (params[:selected_attestation_method_id] || 1).to_i
    @selected_if_attestation_method_id = (params[:selected_if_attestation_method_id] || -1).to_i
    if @selected_if_attestation_method_id > 0
      @if_attestation_method_id = @selected_if_attestation_method_id
    else
      @if_attestation_method_id = @selected_attestation_method_id
    end
    current_if_attestation_method_id = (params[:current_if_attestation_method_id] || -1).to_i
    @selected_if_submission_method_id = (params[:selected_if_submission_method_id] || -1).to_i

    @billing_info_fiscal_year = AttestationRequirementFiscalYear.find_by_mips_billing_active(1)


    @scaling_factor_base_selected = session[:scaling_factor_base].to_s
    @scaling_factor_bonus_selected = session[:scaling_factor_bonus].to_s


    @method_target_value_sets = []

    @x_year_attestation_methods = XYearAttestationMethod.what_if_attestation_methods_by_year(@selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
    @selected_attestation_methods = @x_year_attestation_methods.map {|xyam| [xyam.attestation_method.name, xyam.attestation_method_id]}

    @selected_submission_methods = SubmissionMethod.for_select
    @selected_default_submission_methods = SubmissionMethod.for_select

    @target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
    @x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @target_set.attestation_method_id)

    if @x_year_attestation_method.default_submission_method
      @selected_default_submission_methods.each do |sm|
        if sm[1] == @x_year_attestation_method.default_submission_method_id
          sm[0] += ' *'
        end
      end
    end

    @selected_if_default_submission_method_id = (params[:selected_if_default_submission_method_id] || -1).to_i

    unless @x_year_attestation_method.attestation_method.changeable_flag
      @if_attestation_method_id = @x_year_attestation_method.attestation_method_id
    end
    if @if_attestation_method_id > 0
      @what_if_target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @if_attestation_method_id)
      @if_x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @what_if_target_set.attestation_method_id)

      if @selected_if_attestation_method_id > 0 and current_if_attestation_method_id != @selected_if_attestation_method_id and @if_x_year_attestation_method.default_submission_method and @selected_if_submission_method_id < 0 and @x_year_attestation_method.attestation_method.changeable_flag
        @selected_if_submission_method_id = @if_x_year_attestation_method.default_submission_method_id
      end
    end

    if request.post?
      accepted_security_levels = [1, 2, 3, 6]
      accepted_user_types = [1]
      if accepted_security_levels.include? @user.security_level_id and accepted_user_types.include? @user.user_type_id
        @convert = (params[:convert] || -1).to_s
        if @convert != '-1' and (@if_attestation_method_id > 0 or @selected_if_submission_method_id > 0)
          @department_attestation_requirement_set_details = AttestationRequirementSetDetail.Departments_AttestationRequirementSetDetails_By_EPType_Specialties_UserDefinedFields_TechnologyProduct_DepartmentOwners_CMSProgramType_AttestationDates_AttestationStatus_FiscalYearID_StagingID_RequirementTypeID_EventID_AttestationClinicID(@selected_group, -1, [-1], [-1], [-1], [-1], [-1], [-1], [-1], -1, [-1], -1, [-1], [-1], @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id, -1, -1, @selected_event_id, [@selected_attestation_clinic_id_portal], -1, nil, -1, [-1], @x_year_attestation_method.id, -1, -1, -1)
          @department_attestation_requirement_set_details.each do |arsd|
            if @selected_if_submission_method_id > 0
              arsd.submission_method_id = @selected_if_submission_method_id
            elsif @selected_if_submission_method_id == -1 and arsd.submission_method.nil?
              arsd.submission_method_id = @selected_submission_methods.first[1].to_i
            end
            arsd.x_year_attestation_method_id = @if_x_year_attestation_method.id
            arsd.cqm_manual_override_flag = false
            arsd.save

            calculate_department_cqm_scores(arsd.x_department_attestation_requirement_set_details.first.department, arsd.event)
            calculate_department_cpia_score(arsd.x_department_attestation_requirement_set_details.first.department, arsd.event)
          end

          @selected_attestation_method_id = @if_attestation_method_id
          @target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
          @x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @target_set.attestation_method_id)

          @selected_if_default_submission_method_id = (@x_year_attestation_method.default_submission_method_id || -1).to_i

          @x_year_attestation_methods = XYearAttestationMethod.what_if_attestation_methods_by_year(@selected_attestation_requirement_fiscal_year_id, @selected_attestation_method_id)
          @selected_attestation_methods = @x_year_attestation_methods.map {|xyam| [xyam.attestation_method.name, xyam.attestation_method_id]}


          @selected_if_attestation_method_id = -1
          @what_if_target_set = nil
          @if_x_year_attestation_method = nil
          @selected_if_submission_method_id = -1

          @convert_message = "<span class='yes'>Physicians converted</span>"
        end
      end
    end

    render :layout => "pop_up"
  end

  def update_all_departments_mips_scores
    accepted_user_types = [1]
    accepted_security_levels = [1]
    if accepted_user_types.include? @user.user_type_id and accepted_security_levels.include? @user.security_level_id
      group_id = ((params[:group_id]).to_i)
      fiscal_year_id = ((params[:fiscal_year_id]).to_i)
      if group_id > 0 and fiscal_year_id > 0 and group_id == @selected_group_id
        fiscal_year = AttestationRequirementFiscalYear.find(fiscal_year_id)
        job_history = JobHistory.create(:group_id => group_id, :user_id => @user.id, :job_status => 'Queued',
                                        :job_type => "Component Scores MIPS Refresh - #{fiscal_year.name}", :request_at => @current_time.to_s)

        Delayed::Job.enqueue MipsRefreshJob.new(job_history.id, group_id, fiscal_year_id)
        flash[:notice] = "<span class='yes'>Component Scores MIPS Refresh - #{fiscal_year.name} queued for processing.</span>"
      end
    end

    redirect_to :action => :index
  end

  def tin_summary_aci_multi_date_range_download_csv_file
    attestation_clinic_id = params[:attestation_clinic_id].to_i
    attestation_method_id = params[:attestation_method_id].to_i
    event_id = params[:event_id].to_i
    use_manual_flag = (params[:use_manual_flag].to_i == 1)

    attestation_clinic = AttestationClinic.find(attestation_clinic_id)
    if attestation_clinic.group_id == @selected_group_id
      date_range_list = XClinicEventAttestGroupRequirement.group_aci_requirements_date_ranges_for_tin_summary_download_by_clinic_id_and_attestation_method_id_and_event_id_and_multi_criterion_id(attestation_clinic_id, attestation_method_id, event_id, [2, 3], use_manual_flag)
      base_file_name = attestation_clinic.name
      manual = (use_manual_flag ? 'manual_' : '')
      stream_csv("#{base_file_name}_#{manual}pi_date_ranges_#{@current_time.to_s}.csv") do |csv|
        # Title of report
        csv << "Title of Report: #{attestation_clinic.name} - #{manual}pi_date_ranges"
        csv << "Organization Name: #{attestation_clinic.group.name}"
        csv << ' '

        # header information
        header = []
        header << 'Name'
        header << 'From Date'
        header << 'Through Date'
        csv << header

        # detail information
        date_range_list.each do |date_range|
            display_results = []
            display_results << date_range.name
            display_results << date_range.current_measure_start_date.to_s
            display_results << date_range.current_measure_end_date.to_s

            csv << display_results
        end
      end
    end
  end

  private

  def define_home_subnav
    @selected_side_nav = [['Reporting Entities', 5, 'home', 'index', @selected_page_version_id]]
    @selected_side_nav += [['Component Details', 1, 'home', 'index', @selected_page_version_id]]
    @selected_side_nav += [['Financial Summary', 0, 'home', 'index', @selected_page_version_id]]
    @selected_side_nav += [['Financial Details', 2, 'home', 'index', @selected_page_version_id]]
    @selected_side_nav += [['TIN Comparisons', 8, 'home', 'index', @selected_page_version_id]]

    tin_summary_color_style = nil
    if @tin_summary_attestation_clinics and tin_summary_has_data_errors?(@tin_summary_attestation_clinics)
      tin_summary_color_style = 'class="subnav_error"'
    end
    @selected_side_nav += [['TIN Summary', 10, 'home', 'index', @selected_page_version_id, tin_summary_color_style]]

    qpp_mismatch_color_style = nil
    if @qpp_mismatch_providers and @qpp_mismatch_providers.size == 0
      qpp_mismatch_color_style = 'class="subnav_gray"'
    end
    @selected_side_nav += [['QPP Mismatch', 13, 'home', 'index', @selected_page_version_id, qpp_mismatch_color_style]]

    providers_without_pecos_color_style = nil
    if @providers_without_pecos and @providers_without_pecos.size == 0
      providers_without_pecos_color_style = 'class="subnav_gray"'
    end
    @selected_side_nav += [['Providers without AC', 11, 'home', 'index', @selected_page_version_id, providers_without_pecos_color_style]]

    # @selected_side_nav += [['Submission Methods\Status', 3, 'home', 'index', @selected_page_version_id]]

    accepted_security_levels = [1, 2, 3, 6]
    accepted_user_types = [1]
    if accepted_security_levels.include? @user.security_level_id and accepted_user_types.include? @user.user_type_id
      @selected_side_nav += [['QPP Data Confirmation', 7, 'home', 'index', @selected_page_version_id]]
    end

    # @selected_side_nav += [['MIPS CSV Upload', 4, 'home', 'index']]
    @selected_side_nav += [["Resources#{" (#{@unread_message_count} New)" if @unread_message_count > 0}", 6, 'home', 'index', @selected_page_version_id]]
    @selected_side_nav += [['Financial Peer Review', 12, 'home', 'index', @selected_page_version_id]]
    @selected_side_nav += [['MIPS ScoreCard', 9, 'home', 'index', @selected_page_version_id]]
  end

  def tin_summary_has_data_errors?(attestation_clinics)
    attestation_clinics.each do |attestation_clinic|
      return true if (attestation_clinic.assigned_ec_count.to_i != attestation_clinic.ah_ec_count.to_i)

      x_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic.id, @selected_event_id)
      default_attestation_method_id = (x_clinic_event.nil? ? 0 : x_clinic_event.default_attestation_method_id).to_i
      if x_clinic_event and x_clinic_event.default_attestation_method and x_clinic_event.default_attestation_method.has_clinic_rollup?
        xceam = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, @selected_event_id, x_clinic_event.default_attestation_method_id)
        aci_submit = xceam.nil? ? true : xceam.aci_submit_flag
        quality_submit = xceam.nil? ? true : xceam.quality_submit_flag
        cpia_submit = xceam.nil? ? true : xceam.cpia_submit_flag

        aci_manual = (x_clinic_event.aci_use_manual_fields_flag ? 'manual_' : '')
        aci = attestation_clinic.send("#{aci_manual}advancing_care_info")
        quality_manual = (x_clinic_event.quality_use_manual_fields_flag ? 'manual_' : '')
        cqm = attestation_clinic.send("#{quality_manual}quality")
        cpia = attestation_clinic.cpia
        include_low_volume = x_clinic_event.default_attestation_method.low_volume_included_flag

        aci_multi_date_ranges_flag = (attestation_clinic.send("#{aci_manual}aci_multi_date_ranges_flag").to_i == 1)
        xceagr = XClinicEventAttestGroupRequirement.first_group_aci_requirement_with_date_range_by_clinic_id_and_attestation_method_id_and_event_id(attestation_clinic.id, x_clinic_event.default_attestation_method_id, @selected_event_id, x_clinic_event.aci_use_manual_fields_flag)
        aci_submission_start_date = (xceagr.nil? ? nil : xceagr.aci_start_date)
        aci_submission_end_date = (xceagr.nil? ? nil : xceagr.aci_end_date)

        quality_multi_date_ranges_flag = (attestation_clinic.send("#{quality_manual}quality_multi_date_ranges_flag").to_i == 1)
        quality_submission_start_date = attestation_clinic.send("#{quality_manual}quality_submission_start_date")
        quality_submission_end_date = attestation_clinic.send("#{quality_manual}quality_submission_end_date")

        department_count_with_no_assigned_aci_reqs = 0
        department_count_with_no_assigned_quality_reqs = 0
        department_count_with_no_assigned_cpia_reqs = 0

        xdcs_id_with_cpia = XDepartmentCriterionRequirement.xdcs_id_with_most_points_by_clinic_id_and_attestation_method_id_and_event_id(attestation_clinic.id, x_clinic_event.default_attestation_method_id, @selected_event_id)
      else
        aci_submit = x_clinic_event.nil? ? true : x_clinic_event.aci_submit_flag
        quality_submit = x_clinic_event.nil? ? true : x_clinic_event.quality_submit_flag
        cpia_submit = x_clinic_event.nil? ? true : x_clinic_event.cpia_submit_flag

        aci = attestation_clinic.indiv_avg_advancing_care_info
        cqm = attestation_clinic.indiv_avg_quality
        cpia = attestation_clinic.indiv_avg_cpia
        include_low_volume = (x_clinic_event.nil? or x_clinic_event.default_attestation_method.nil? ? false : x_clinic_event.default_attestation_method.low_volume_included_flag)
        aci_multi_date_ranges_flag = false
        aci_submission_start_date = 'N/A'
        aci_submission_end_date = 'N/A'
        quality_multi_date_ranges_flag = false
        quality_submission_start_date = 'N/A'
        quality_submission_end_date = 'N/A'

        department_count_with_no_assigned_aci_reqs = Department.count_departments_with_no_assigned_aci_requirements_by_group_id_and_attestation_clinic_id_and_event_id(attestation_clinic.group_id, attestation_clinic.id, @selected_event_id)
        department_count_with_no_assigned_quality_reqs = Department.count_departments_with_no_assigned_requirements_by_group_id_and_attestation_clinic_id_and_event_id_and_criterion_id(attestation_clinic.group_id, attestation_clinic.id, @selected_event_id, 4)
        department_count_with_no_assigned_cpia_reqs = Department.count_departments_with_no_assigned_requirements_by_group_id_and_attestation_clinic_id_and_event_id_and_criterion_id(attestation_clinic.group_id, attestation_clinic.id, @selected_event_id, 5)

        xdcs_id_with_cpia = '' # Not applicable for Individual type Attestation Method, uses department_count_with_no_assigned_cpia_reqs instead
      end
      cpia_not_assigned = (xdcs_id_with_cpia.nil? or department_count_with_no_assigned_cpia_reqs > 0)

      return true if ((aci_submit and aci.to_s.length == 0) or (quality_submit and cqm.to_s.length == 0) or (cpia_submit and cpia.to_s.length == 0))

      return true if ((aci_submit and department_count_with_no_assigned_aci_reqs > 0) or (quality_submit and department_count_with_no_assigned_quality_reqs > 0) or (cpia_submit and cpia_not_assigned))

      # aci_measure_dates = XDepartmentCriterionRequirement.aci_min_max_requirement_date_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, @selected_event_id, default_attestation_method_id, include_low_volume)
      # quality_measure_dates = XDepartmentCriterionRequirement.quality_min_max_requirement_date_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, @selected_event_id, default_attestation_method_id, include_low_volume)
      return true if ((aci_submit and (aci_multi_date_ranges_flag or aci_submission_start_date.nil? or aci_submission_end_date.nil?)) or (quality_submit and (quality_multi_date_ranges_flag or quality_submission_start_date.nil? or quality_submission_end_date.nil?)))

      return true if (x_clinic_event.nil? or x_clinic_event.default_attestation_method.nil?)
    end
    false
  end

  def all_clinic_forecast_scores(attestation_clinics, event_id, fiscal_year_id, aco_entity_type_id, group_entity_type_id, individual_entity_type_id, scoring_method, scaling_base, scaling_bonus)
    all_clinic_results = {}

    x_year_aco_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(fiscal_year_id, aco_entity_type_id)
    x_year_group_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(fiscal_year_id, group_entity_type_id)
    x_year_individual_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(fiscal_year_id, individual_entity_type_id)

    aco_lv_included = (x_year_aco_method.attestation_method.low_volume_included_flag ? 1 : 0)
    group_lv_included = (x_year_group_method.attestation_method.low_volume_included_flag ? 1 : 0)
    individual_lv_included = (x_year_individual_method.attestation_method.low_volume_included_flag ? 1 : 0)

    group_financial_method = XAttestationRequirementFiscalYearFinancialMethodType.find_by_attestation_requirement_fiscal_year_id_and_financial_method_type_id(fiscal_year_id, x_year_group_method.attestation_method.financial_method_type_id)
    individual_financial_method = XAttestationRequirementFiscalYearFinancialMethodType.find_by_attestation_requirement_fiscal_year_id_and_financial_method_type_id(fiscal_year_id, x_year_individual_method.attestation_method.financial_method_type_id)

    selected_department_owner_id = -1
    billing_info_fiscal_year = AttestationRequirementFiscalYear.find_by_mips_billing_active(1)
    forecast_year_name = billing_info_fiscal_year.mips_forecast_name

    total_ec_count = total_base_medicare = total_aco_result = total_group_result = total_individual_result = total_current_result = 0

    macra_struct = Struct.new(:advancing_care_info, :quality, :resource_use, :cpia)
    attestation_clinics.each do |attestation_clinic|
      all_clinic_results[attestation_clinic.id] = {}
      all_clinic_results[attestation_clinic.id][:aco_result] = {}
      clinic_ec_count = clinic_base_medicare = clinic_aco_results = clinic_group_results = clinic_individual_results = clinic_current_results = 0

      # Group Section
      if event_id > 0
        possible_events = [Event.find(event_id)]
      else
        possible_events = Event.find_all_by_attestation_requirement_fiscal_year_id_and_group_type_id(fiscal_year_id, attestation_clinic.group.group_type_id)
      end
      xceams = {}
      possible_events.each do |possible_event|
        xceams["#{possible_event.id}"] = {}
        all_clinic_results[attestation_clinic.id][:aco_result]["#{possible_event.id}"] = {}
        # TODO what to do if there is no default_submission_method_id
        group_submission_method_id = (x_year_group_method.default_submission_method_id || SubmissionMethod.ehr_id)
        test_event = Event.find(possible_event.id)
        if scoring_method == 1
          group_quality_score = forecast_clinic_quality_score(attestation_clinic, test_event, x_year_group_method, group_submission_method_id)
          group_aci_score = forecast_clinic_aci_score(attestation_clinic, test_event, x_year_group_method, group_submission_method_id)
          group_cpia_score = forecast_clinic_cpia_score(attestation_clinic, test_event, x_year_group_method)
        else
          x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, test_event.id, group_entity_type_id)
          if x_clinic_event_attest_method
            group_quality_score = x_clinic_event_attest_method.cms_quality.to_f
            group_aci_score = x_clinic_event_attest_method.cms_advancing_care_info.to_f
            group_cpia_score = x_clinic_event_attest_method.cms_cpia.to_f
          else
            group_quality_score = 0
            group_aci_score = 0
            group_cpia_score = 0
          end
        end
        xceams["#{possible_event.id}"][:quality] = group_quality_score
        xceams["#{possible_event.id}"][:advancing_care_info] = group_aci_score
        xceams["#{possible_event.id}"][:cpia] = group_cpia_score

        # TODO what to do if there is no default_submission_method_id
        aco_submission_method_id = (x_year_aco_method.default_submission_method_id || SubmissionMethod.cms_web_interface_id)
        if scoring_method == 1
          aco_quality_score = forecast_clinic_quality_score(attestation_clinic, test_event, x_year_aco_method, aco_submission_method_id)
          aco_aci_score = forecast_clinic_aci_score(attestation_clinic, test_event, x_year_aco_method, aco_submission_method_id)
          aco_cpia_score = forecast_clinic_cpia_score(attestation_clinic, test_event, x_year_aco_method)
        else
          x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, test_event.id, aco_entity_type_id)
          if x_clinic_event_attest_method
            aco_quality_score = x_clinic_event_attest_method.cms_quality.to_f
            aco_aci_score = x_clinic_event_attest_method.cms_advancing_care_info.to_f
            aco_cpia_score = x_clinic_event_attest_method.cms_cpia.to_f
          else
            aco_quality_score = 0
            aco_aci_score = 0
            aco_cpia_score = 0
          end
        end
        aco_macra_entity = macra_struct.new(aco_aci_score, aco_quality_score, nil, aco_cpia_score)
        all_clinic_results[attestation_clinic.id][:aco_result]["#{possible_event.id}"][:score] = calculate_composite_score(aco_macra_entity, x_year_aco_method).to_f
        all_clinic_results[attestation_clinic.id][:aco_result]["#{possible_event.id}"][:ec_count] = 0
        all_clinic_results[attestation_clinic.id][:aco_result]["#{possible_event.id}"][:base_medicare] = 0
      end

      departments = Department.Group_Departments_For_Forecast_By_GroupID_ClinicID_EventID_DepartmentOwnerID_BillingYear(attestation_clinic.group_id, attestation_clinic.id, event_id, selected_department_owner_id, billing_info_fiscal_year.id, fiscal_year_id)
      clinic_ec_count += departments.size
      event_attest_method_scores_hash = {}
      departments.each do |department|
        dep_medicare_allowed = (department ? department.total_medicare_payment_amt : 0).to_f
        clinic_base_medicare += dep_medicare_allowed
        arsd = AttestationRequirementSetDetail.find(department.arsd_id)

        temp_aci_score = department.advancing_care_info
        # Current Section
        if arsd.x_year_attestation_method and (arsd.x_year_attestation_method.attestation_method.low_volume_included_flag or department.low_volume_flag.to_i == 0)
          x_fiscal_year_financial_method = XAttestationRequirementFiscalYearFinancialMethodType.find_by_attestation_requirement_fiscal_year_id_and_financial_method_type_id(arsd.event.attestation_requirement_fiscal_year_id, arsd.x_year_attestation_method.attestation_method.financial_method_type_id)

          if arsd.x_year_attestation_method.attestation_method.has_group_rollup?
            x_group_year_attest_method = XGroupYearAttestMethod.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(department.group_id, arsd.event.attestation_requirement_fiscal_year_id, arsd.x_year_attestation_method.attestation_method_id)
            if x_group_year_attest_method.nil?
              # if current_scores == -1
              department.quality = 0
              department.cpia = 0
              department.advancing_care_info = 0
            else
              department.quality = x_group_year_attest_method.quality
              department.cpia = x_group_year_attest_method.cpia
              department.advancing_care_info = x_group_year_attest_method.advancing_care_info
            end
          elsif arsd.x_year_attestation_method.attestation_method.has_clinic_rollup?
            # attest_method_scores_hash = event_attest_method_scores_hash[arsd.event_id]
            # if attest_method_scores_hash.nil?
            #   event_attest_method_scores_hash[arsd.event_id] = {}
            #   attest_method_scores_hash = {}
            # end
            # current_scores = attest_method_scores_hash[arsd.x_year_attestation_method.attestation_method_id]
            # if current_scores.nil?
            #   x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, arsd.event_id, arsd.x_year_attestation_method.attestation_method_id)
            #   if x_clinic_event_attest_method.nil?
            #     x_clinic_event_attest_method = -1
            #   end
            #   event_attest_method_scores_hash[arsd.event_id][arsd.x_year_attestation_method.attestation_method_id] = x_clinic_event_attest_method
            #   current_scores = x_clinic_event_attest_method
            # end

            x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic.id, arsd.event_id, arsd.x_year_attestation_method.attestation_method_id)
            if x_clinic_event_attest_method.nil?
            # if current_scores == -1
              department.quality = 0
              department.cpia = 0
              department.advancing_care_info = 0
            else
              department.quality = x_clinic_event_attest_method.quality
              department.cpia = x_clinic_event_attest_method.cpia
              department.advancing_care_info = x_clinic_event_attest_method.advancing_care_info
            end
          end

          clinic_current_results += calculate_financial_impact(department, arsd.x_year_attestation_method, x_fiscal_year_financial_method, scaling_base.to_f, scaling_bonus.to_f)
        end

        # Individual Section
        if scoring_method == 1 and (individual_lv_included == 1 or (individual_lv_included == 0 and department.low_volume_flag.to_i == 0))
          x_event_attestation_method = XEventAttestationMethod.find_by_event_id_and_attestation_method_id(arsd.event_id, x_year_individual_method.attestation_method.id)
          department.quality = what_if_department_quality_score(department, arsd, x_year_individual_method, x_event_attestation_method)
          department.cpia = what_if_department_cpia_score(department, arsd, x_year_individual_method)
          # mips_scores = TempMipsIndivScoreboard.find_by_department_id_and_event_id(department.id, arsd.event_id)
          department.advancing_care_info = temp_aci_score
          # aci_score = (mips_scores.nil? ? 0 : mips_scores.advancing_care_info)
          dep_score = (department ? calculate_composite_score(department, x_year_individual_method) : 0).to_f
          clinic_individual_results += calculate_dollar_amount(dep_score/100.0, dep_medicare_allowed, individual_financial_method, scaling_base.to_f, scaling_bonus.to_f)
        end

        # Group Section
        if group_lv_included == 1 or (group_lv_included == 0 and department.low_volume_flag.to_i == 0)
          department.quality = xceams["#{arsd.event_id}"][:quality]
          department.advancing_care_info = xceams["#{arsd.event_id}"][:advancing_care_info]
          department.cpia = xceams["#{arsd.event_id}"][:cpia]
          dep_score = (department ? calculate_composite_score(department, x_year_group_method) : 0).to_f
          clinic_group_results += calculate_dollar_amount(dep_score/100.0, dep_medicare_allowed, group_financial_method, scaling_base.to_f, scaling_bonus.to_f)
        end

        if aco_lv_included == 1 or (group_lv_included == 0 and department.low_volume_flag.to_i == 0)
          all_clinic_results[attestation_clinic.id][:aco_result]["#{arsd.event_id}"][:ec_count] += 1
          all_clinic_results[attestation_clinic.id][:aco_result]["#{arsd.event_id}"][:base_medicare] += dep_medicare_allowed
        end
      end
      all_clinic_results[attestation_clinic.id][:ec_count] = clinic_ec_count
      all_clinic_results[attestation_clinic.id][:base_medicare] = clinic_base_medicare
      # all_clinic_results[attestation_clinic.id][:aco_result] = clinic_aco_results
      all_clinic_results[attestation_clinic.id][:group_result] = clinic_group_results
      all_clinic_results[attestation_clinic.id][:individual_result] = clinic_individual_results
      all_clinic_results[attestation_clinic.id][:current_result] = clinic_current_results
      total_ec_count += clinic_ec_count
      total_base_medicare += clinic_base_medicare
      total_aco_result += clinic_aco_results
      total_group_result += clinic_group_results
      total_individual_result += clinic_individual_results
      total_current_result += clinic_current_results
    end
    all_clinic_results[:total_ec_count] = total_ec_count
    all_clinic_results[:total_base_medicare] = total_base_medicare
    # all_clinic_results[:total_aco_result] = total_aco_result
    all_clinic_results[:total_group_result] = total_group_result
    all_clinic_results[:total_individual_result] = total_individual_result
    all_clinic_results[:total_current_result] = total_current_result

    all_clinic_results
  end

  def what_if_department_quality_score(department, arsd, x_year_attestation_method, x_event_attestation_method)
    selected_cqm_selection_template_id = -1
    # TODO what to do if there is no default_submission_method_id
    submission_method_id = (x_year_attestation_method.default_submission_method_id || SubmissionMethod.ehr_id)
    if x_event_attestation_method.default_cqm_selection_template
      selected_cqm_selection_template_id = x_event_attestation_method.default_cqm_selection_template_id
    end
    redo_scores = (submission_method_id != arsd.submission_method_id.to_i)
    cqm_score_denominator = x_year_attestation_method.cqm_score_denominator.to_i

    if selected_cqm_selection_template_id > 0
      selected_cqm_selection_template = CqmSelectionTemplate.find(selected_cqm_selection_template_id)
      template_score_denominator = selected_cqm_selection_template.requirements_assigned_by_submission_method_id(submission_method_id) * 10
      cqm_score_denominator = [template_score_denominator, cqm_score_denominator].min
    end

    priority_bonus_maximum = cqm_score_denominator.to_f / 10.0
    cehrt_bonus_maximum = cqm_score_denominator.to_f / 10.0

    date_range = ((arsd.quality_submission_start_date.nil? or arsd.quality_submission_end_date.nil?) ? nil : "#{arsd.quality_submission_start_date.strftime('%m/%d/%Y')}-#{arsd.quality_submission_end_date.strftime('%m/%d/%Y')}")
    select_date_range = XDepartmentCriterionRequirement.group_requirements_date_ranges_for_select_by_department_and_attestation_clinic_id_and_criterion_id_and_event_id_and_submission_method_id_and_req_measure_type_id(department, arsd.x_department_attestation_requirement_set_details.first.attestation_clinic_id, 4, arsd.event_id, submission_method_id, -1, selected_cqm_selection_template_id)
    if (date_range.nil? or !select_date_range.include?(date_range)) and select_date_range.size > 0
      date_range = select_date_range.first[1]
    else
      date_range = nil
    end
    if date_range.nil?
      current_measure_start_date = nil
      current_measure_end_date = nil
    else
      current_measure_start_date = Date.parse(date_range.split('-')[0])
      current_measure_end_date = Date.parse(date_range.split('-')[1])
    end
    department_requirements = XDepartmentCriterionRequirement.required_first_group_requirements_for_cqm_selector_by_department_and_attestation_clinic_id_and_criterion_id_and_event_id_and_submission_method_id_and_req_measure_type_id(department, arsd.x_department_attestation_requirement_set_details.first.attestation_clinic_id, 4, arsd.event_id, submission_method_id, -1, current_measure_start_date, current_measure_end_date, selected_cqm_selection_template_id)


    # if redo_scores
    department_requirements.each do |x_dep_req|
      x_dep_req.performance_rate = calculate_department_requirement_performance_rate(x_dep_req)
      x_dep_req.decile_points = calculate_department_requirement_decile_score(x_dep_req)
      priority_bonus_points = 0
      cehrt_bonus_points = 0
      if x_dep_req.decile_points > 0
        priority_bonus_points = calculate_department_requirement_priority_bonus_score(x_dep_req)
        cehrt_bonus_points = calculate_department_requirement_cehrt_bonus_score(x_dep_req)
      end
      x_dep_req.priority_bonus_points = priority_bonus_points
      x_dep_req.cehrt_bonus_points = cehrt_bonus_points
    end
    department_requirements = department_requirements.sort_by { |a| [a.template_active.to_i*-1, a.total_decile_points*-1, a.x_group_requirement.requirement_identifier.length, a.x_group_requirement.requirement_identifier, a.x_group_requirement.requirement_id] }
    required_requirement_index = nil
    department_requirements.each_with_index do |x_dep_req, i|
      if required_requirement_index.nil? and x_dep_req.x_group_requirement.requirement.high_priority_flag
        required_requirement_index = i
      end
      if [3, 5].include? x_dep_req.requirement.cqm_type_id.to_i
        required_requirement_index = i
        break
      end
    end

    if required_requirement_index
      department_requirements.unshift(department_requirements.delete_at(required_requirement_index))
      department_requirements.first.priority_bonus_points = 0
    end
    # else
    # if redo_scores
    #   calculate_department_cqm_scores(@selected_department, arsd.event)
    # else
    #   calculate_department_quality_score(@selected_department, arsd.event)
    # end
    # department_requirements = XDepartmentCriterionRequirement.group_requirements_for_cqm_selector_by_department_and_criterion_id_and_event_id_and_submission_method_id_and_req_measure_type_id(@selected_department, 4, @attestation_requirement_set_detail.event_id, @selected_submission_method_id, -1)
    # end

    target_selected_number = x_year_attestation_method.cqm_target_selected_number.to_i
    # if selected_cqm_selection_template_id == -1
    #   department_requirements = department_requirements[0..target_selected_number]
    # elsif selected_cqm_selection_template_id > 0
    #   department_requirements = department_requirements[0..target_selected_number]
    # end

    cur_priority_bonus_points = 0
    cur_cehrt_bonus_points = 0
    selected_number = 0
    decile_points_list = []
    department_requirements.each do |x_dep_req|
      if selected_cqm_selection_template_id > 0
        if (selected_number < target_selected_number or (cur_priority_bonus_points < priority_bonus_maximum and x_dep_req.priority_bonus_points.to_f > 0)) and x_dep_req.xrsm_id
          x_cqm_template_group_requirement = x_dep_req.x_group_requirement.requirement.x_cqm_template_group_requirements.find_by_cqm_selection_template_id(selected_cqm_selection_template_id)
          selected_box = (!x_cqm_template_group_requirement.nil? and x_cqm_template_group_requirement.active)
        else
          selected_box = false
        end
      else
        if (selected_number < target_selected_number or (cur_priority_bonus_points < priority_bonus_maximum and x_dep_req.priority_bonus_points.to_f > 0)) and x_dep_req.xrsm_id
          selected_box = true
        else
          selected_box = false
        end
      end

      if selected_box
        selected_number += 1
        cur_priority_bonus_points += x_dep_req.priority_bonus_points.to_i
        cur_cehrt_bonus_points += x_dep_req.cehrt_bonus_points.to_i
        decile_points_list << x_dep_req.decile_points.to_f
      end
    end
    total_cqm_points = decile_points_list.sort.reverse[0...target_selected_number].sum

    if cqm_score_denominator > 0
      total_cqm_points += [priority_bonus_maximum, cur_priority_bonus_points].min
      total_cqm_points += [cehrt_bonus_maximum, cur_cehrt_bonus_points].min
      quality_score = total_cqm_points.to_f / cqm_score_denominator * 100.0
    end
    [100.0, quality_score.to_f].min
  end

  def what_if_department_cpia_score(department, arsd, x_year_attestation_method)
    cpia_total_points = 0
    department_criterion_requirements = XDepartmentCriterionRequirement.department_requirements_by_department_id_event_id_attestation_clinic_id_active_criterion_status_id(department.id, arsd.event_id, arsd.x_department_attestation_requirement_set_details.first.attestation_clinic_id, 1, 5, -1, -1)
    department_criterion_requirements.each do |department_criterion_requirement|
      if department_criterion_requirement.active and department_criterion_requirement.cpia_select_flag
        cpia_total_points += department_criterion_requirement.requirement.score
      end
    end
    cpia_score = cpia_total_points.to_f / x_year_attestation_method.cpia_score_denominator.to_i * 100.0
    if cpia_score < 50
      cpia_score = 0
    elsif cpia_score < 100
      cpia_score = 50
    else
      cpia_score = 100
    end
    cpia_score
  end

  def forecast_clinic_quality_score(clinic, event, x_year_attestation_method, submission_method_id)
    quality_score = 0
    x_event_attestation_method = XEventAttestationMethod.find_by_event_id_and_attestation_method_id(event.id, x_year_attestation_method.attestation_method_id)
    selected_cqm_selection_template_id = -1
    if x_event_attestation_method.default_cqm_selection_template
      selected_cqm_selection_template_id = x_event_attestation_method.default_cqm_selection_template_id
    end
    # @redo_scores = (submission_method_id != @quality_entity.submission_method_id.to_i)
    cqm_score_denominator = x_year_attestation_method.cqm_score_denominator.to_i

    if selected_cqm_selection_template_id > 0
      selected_cqm_selection_template = CqmSelectionTemplate.find(selected_cqm_selection_template_id)
      template_score_denominator = selected_cqm_selection_template.requirements_assigned_by_submission_method_id(submission_method_id) * 10
      cqm_score_denominator = [template_score_denominator, cqm_score_denominator].min
    end

    priority_bonus_maximum = cqm_score_denominator.to_f / 10.0
    cehrt_bonus_maximum = cqm_score_denominator.to_f / 10.0

    xace = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(clinic.id, event.id)
    x_clinic_event_attest_method = nil
    use_manual_flag = false
    if xace and xace.default_attestation_method and xace.default_attestation_method.has_clinic_rollup?
      x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(clinic.id, event.id, xace.default_attestation_method_id)
      if x_clinic_event_attest_method.nil?
        use_manual_flag = false
      else
        use_manual_flag = x_clinic_event_attest_method.quality_use_manual_fields_flag
      end
    end

    if use_manual_flag
      current_measure_start_date = x_clinic_event_attest_method.manual_quality_submission_start_date
      current_measure_end_date = x_clinic_event_attest_method.manual_quality_submission_end_date
      department_requirements = XClinicEventAttestGroupRequirement.group_requirements_for_cqm_selector_by_clinic_id_and_attestation_method_id_and_criterion_id_and_event_id_and_submission_method_id_and_req_measure_type_id(clinic.id, x_clinic_event_attest_method.attestation_method_id, 4, event.id, submission_method_id, -1, current_measure_start_date, current_measure_end_date, selected_cqm_selection_template_id, -1, -1, use_manual_flag)
    else
      date_range = ((x_clinic_event_attest_method.nil? or x_clinic_event_attest_method.quality_submission_start_date.nil? or x_clinic_event_attest_method.quality_submission_start_date.nil?) ? nil : "#{x_clinic_event_attest_method.quality_submission_start_date.strftime('%m/%d/%Y')}-#{x_clinic_event_attest_method.quality_submission_end_date.strftime('%m/%d/%Y')}")
      select_date_range = XDepartmentCriterionRequirement.group_requirements_for_forecast_date_select_by_criterion_id_and_event_id_and_submission_method_id_and_req_measure_type_id(clinic.group_id, clinic.id, ['4'], event.id, submission_method_id, -1, selected_cqm_selection_template_id)
      is_selected_date_range_in_list = false
      unless select_date_range.nil?
        select_date_range.each do |date_range_select_pair|
          is_selected_date_range_in_list = (is_selected_date_range_in_list or date_range_select_pair[1] == date_range)
        end
      end
      if !is_selected_date_range_in_list and select_date_range.size > 0
        date_range = select_date_range.first[1]
      elsif !is_selected_date_range_in_list and select_date_range.size == 0
        date_range = nil
      end

      if date_range.nil?
        current_measure_start_date = nil
        current_measure_end_date = nil
      else
        current_measure_start_date = Date.parse(date_range.split('-')[0])
        current_measure_end_date = Date.parse(date_range.split('-')[1])
      end

      department_requirements = XDepartmentCriterionRequirement.group_requirements_for_forecast_by_criterion_id_and_event_id_and_submission_method_id_and_req_measure_type_id(clinic.group_id, clinic.id, [4], event.id, submission_method_id, -1, current_measure_start_date, current_measure_end_date, selected_cqm_selection_template_id)
    end


    # if @redo_scores
    department_requirements.each do |x_dep_req|
      x_dep_req.performance_rate = calculate_department_requirement_performance_rate_for_group_forecast(x_dep_req, current_measure_start_date, current_measure_end_date, use_manual_flag)
      x_dep_req.decile_points = calculate_department_requirement_decile_score(x_dep_req)
      priority_bonus_points = 0
      cehrt_bonus_points = 0
      if x_dep_req.decile_points > 0
        priority_bonus_points = calculate_department_requirement_priority_bonus_score(x_dep_req)
        cehrt_bonus_points = calculate_department_requirement_cehrt_bonus_score(x_dep_req)
      end
      x_dep_req.priority_bonus_points = priority_bonus_points
      x_dep_req.cehrt_bonus_points = cehrt_bonus_points
    end
    department_requirements = department_requirements.sort_by { |a| [a.template_active.to_i*-1, a.total_decile_points*-1, a.x_group_requirement.requirement_identifier.length, a.x_group_requirement.requirement_identifier, a.x_group_requirement.requirement_id] }
    required_requirement_index = nil
    department_requirements.each_with_index do |x_dep_req, i|
      if required_requirement_index.nil? and x_dep_req.x_group_requirement.requirement.high_priority_flag
        required_requirement_index = i
      end
      if [3, 5].include? x_dep_req.requirement.cqm_type_id.to_i
        required_requirement_index = i
        break
      end
    end

    if required_requirement_index
      department_requirements.unshift(department_requirements.delete_at(required_requirement_index))
      department_requirements.first.priority_bonus_points = 0
    end

    target_selected_number = x_year_attestation_method.cqm_target_selected_number.to_i
    # if selected_cqm_selection_template_id == -1
    #   department_requirements = department_requirements[0..target_selected_number]
    # elsif selected_cqm_selection_template_id > 0
    #   department_requirements = department_requirements[0..target_selected_number]
    # end

    cur_priority_bonus_points = 0
    cur_cehrt_bonus_points = 0
    selected_number = 0
    decile_points_list = []
    department_requirements.each do |x_dep_req|
      if selected_cqm_selection_template_id > 0
        if (selected_number < target_selected_number or (cur_priority_bonus_points < priority_bonus_maximum and x_dep_req.priority_bonus_points.to_f > 0)) and x_dep_req.xrsm_id
          x_cqm_template_group_requirement = x_dep_req.x_group_requirement.requirement.x_cqm_template_group_requirements.find_by_cqm_selection_template_id(selected_cqm_selection_template_id)
          selected_box = (!x_cqm_template_group_requirement.nil? and x_cqm_template_group_requirement.active)
        else
          selected_box = false
        end
      else
        if (selected_number < target_selected_number or (cur_priority_bonus_points < priority_bonus_maximum and x_dep_req.priority_bonus_points.to_f > 0)) and x_dep_req.xrsm_id
          selected_box = true
        else
          selected_box = false
        end
      end

      if selected_box
        selected_number += 1
        cur_priority_bonus_points += x_dep_req.priority_bonus_points.to_i
        cur_cehrt_bonus_points += x_dep_req.cehrt_bonus_points.to_i
        decile_points_list << x_dep_req.decile_points.to_f
      end
    end
    total_cqm_points = decile_points_list.sort.reverse[0...target_selected_number].sum

    if cqm_score_denominator > 0
      total_cqm_points += [priority_bonus_maximum, cur_priority_bonus_points].min
      total_cqm_points += [cehrt_bonus_maximum, cur_cehrt_bonus_points].min
      quality_score = total_cqm_points.to_f / cqm_score_denominator * 100.0
    end
    [100.0, quality_score.to_f].min
  end

  def forecast_clinic_aci_score(clinic, event, x_year_attestation_method, submission_method_id)
    base_score = event.attestation_requirement_fiscal_year.mips_aci_base_points
    bonus_score = 0
    performance_bonus_score = 0

    xace = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(clinic.id, event.id)
    x_clinic_event_attest_method = nil
    use_manual_flag = false
    if xace and xace.default_attestation_method and xace.default_attestation_method.has_clinic_rollup?
      x_clinic_event_attest_method = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(clinic.id, event.id, xace.default_attestation_method_id)
      if x_clinic_event_attest_method.nil?
        use_manual_flag = false
      else
        use_manual_flag = x_clinic_event_attest_method.aci_use_manual_fields_flag
      end
    end

    if use_manual_flag
      x_clinic_requirements = XClinicEventAttestGroupRequirement.group_requirements_for_forecast_manual_aci_by_clinic_id_and_attestation_method_id_and_event_id_and_multi_criterion_id(clinic.id, x_clinic_event_attest_method.attestation_method_id, event.id, [2, 3])
    else
      x_clinic_requirements = XDepartmentCriterionRequirement.group_requirements_for_forecast_aci_by_criterion_id_and_event_id(clinic.id, event.id, [2, 3])
      x_clinic_requirements.each do |x_clinic_requirement|
        if x_clinic_requirement.r_measure_type_id.to_i == 3
          x_clinic_requirement.numerator = [1, x_clinic_requirement.total_numerator.to_i].min
          x_clinic_requirement.denominator = [1, x_clinic_requirement.total_denominator.to_i].min
          x_clinic_requirement.exclusion_flag = x_clinic_requirement.total_exclusion_flag.to_i
        else
          x_clinic_requirement.numerator = x_clinic_requirement.total_numerator.to_i
          x_clinic_requirement.denominator = x_clinic_requirement.total_denominator.to_i
          x_clinic_requirement.exclusion_flag = x_clinic_requirement.total_exclusion_flag.to_i
        end
        # x_clinic_requirement.current_measure_start_date = x_clinic_requirement.aci_current_measure_start_date
        # x_clinic_requirement.current_measure_end_date = x_clinic_requirement.aci_current_measure_end_date
      end
    end

    x_clinic_requirements.each do |x_clinic_requirement|
      if base_score == event.attestation_requirement_fiscal_year.mips_aci_base_points
        # if x_clinic_requirement.r_measure_type_id.to_i == 3
        #   x_clinic_requirement.numerator = [1, x_clinic_requirement.numerator.to_i].min
        #   x_clinic_requirement.denominator = [1, x_clinic_requirement.denominator.to_i].min
        # end
        if x_clinic_requirement.r_required_for_base_score_flag.to_i == 1 and x_clinic_requirement.numerator.to_i == 0 and x_clinic_requirement.exclusion_flag.to_i == 0
          base_score = 0
        end
        case x_clinic_requirement.r_aci_scoring_type_id.to_i
          when 2
            if x_clinic_requirement.numerator.to_i > 0
              bonus_score += 10
            end
          when 3
            if x_clinic_requirement.denominator.to_i > 0 and x_clinic_requirement.numerator.to_i > 0
              calc_score = (x_clinic_requirement.numerator.to_f/x_clinic_requirement.denominator.to_f) * 10.0
              calc_score = ((calc_score * 10.0).round.to_f / 10.0).ceil
              bonus_score += calc_score
            end
          when 4
            if x_clinic_requirement.denominator.to_i > 0 and x_clinic_requirement.numerator.to_i > 0
              calc_score = (x_clinic_requirement.numerator.to_f/x_clinic_requirement.denominator.to_f) * 10.0 * 2
              calc_score = ((calc_score * 10.0).round.to_f / 10.0).ceil
              bonus_score += calc_score
            end
          when 6
            if x_clinic_requirement.denominator.to_i > 0 and x_clinic_requirement.numerator.to_i > 0
              calc_score = (x_clinic_requirement.numerator.to_f/x_clinic_requirement.denominator.to_f) * 10.0 * 4
              calc_score = ((calc_score * 10.0).round.to_f / 10.0).ceil
              bonus_score += calc_score
            end
        end
        if x_clinic_requirement.r_aci_performance_bonus_points and x_clinic_requirement.numerator.to_i > 0
          performance_bonus_score += x_clinic_requirement.r_aci_performance_bonus_points.to_f
        end
      end
    end

    aci_base_score = base_score

    aci_bonus_score = bonus_score
    max = 15
    aci_performance_bonus_score = [performance_bonus_score, max].min

    ((aci_base_score == event.attestation_requirement_fiscal_year.mips_aci_base_points) ? [aci_base_score + aci_bonus_score + aci_performance_bonus_score,100].min : 0)
  end

  def forecast_clinic_cpia_score(clinic, event, x_year_attestation_method)
    cpia_total_points = XDepartmentCriterionRequirement.max_cpia_points_by_clinic_id_and_attestation_method_id_and_event_id(clinic.id, x_year_attestation_method.attestation_method_id, event.id)

    cpia_score = cpia_total_points.to_f / x_year_attestation_method.cpia_score_denominator.to_i * 100.0
    if cpia_score < 50
      cpia_score = 0
    elsif cpia_score < 100
      cpia_score = 50
    else
      cpia_score = 100
    end

    cpia_score
  end

  def mips_csv_upload
    if !params[:mips_csv_upload].nil? and params[:mips_csv_upload].size > 0
      event = Event.find @selected_event_id
      yearly_aci_base_score = event.attestation_requirement_fiscal_year.mips_aci_base_points
      csv_upload = params[:mips_csv_upload].read
      parsed_csv_upload = FasterCSV.parse(csv_upload, :headers => true)
      @csv_row_count = parsed_csv_upload.size
      parsed_csv_upload.each do |row|
        temp_name = (row[0].nil?) ? "" : row[0].strip
        temp_tin = (row[1].nil?) ? "" : row[1].strip.gsub('-','')
        temp_npi = (row[2].nil?) ? "" : row[2].strip
        temp_physician_compare_status = (row[3].nil?) ? "" : row[3].strip
        temp_advancing_care_info = (row[4].nil?) ? "" : row[4].strip
        temp_quality = (row[5].nil?) ? "" : row[5].strip
        temp_resource_use = (row[6].nil?) ? "" : row[6].strip
        temp_cpia = (row[7].nil?) ? "" : row[7].strip
        if temp_tin.length > 0 and temp_npi.length > 0
          department = Department.find_by_TIN_and_npi(temp_tin, temp_npi)
          if !department.nil?
            mips_scoreboard = TempMipsIndivScoreboard.find_by_department_id_and_event_id(department.id, @selected_event_id)
            if mips_scoreboard.nil?
              mips_scoreboard = TempMipsIndivScoreboard.new
              mips_scoreboard.department_id = department.id
              mips_scoreboard.event_id = @selected_event_id
            end
          else
            clinic = AttestationClinic.find_by_TIN_and_npi(temp_tin, temp_npi)
            if !clinic.nil?
              mips_scoreboard = TempMipsGroupScoreboard.find_by_attestation_clinic_id_and_event_id(clinic.id, @selected_event_id)
              if mips_scoreboard.nil?
                mips_scoreboard = TempMipsGroupScoreboard.new
                mips_scoreboard.attestation_clinic_id = clinic.id
                mips_scoreboard.event_id = @selected_event_id
              end
            end
          end
          if !mips_scoreboard.nil?
            mips_scoreboard.physician_compare_status = temp_physician_compare_status
            if @selected_group.mips_aci_calc_flag || ApplicationConfiguration.get_mips_aci_calc_flag
              event = Event.find @selected_event_id
              aci_base_score = calculate_department_aci_base_score(department, event)

              aci_bonus_score = calculate_department_aci_bonus_score(department, event)
              aci_performance_bonus_score = calculate_department_aci_performance_bonus_score(department, event)

              aci_base_requirements_completed = (aci_base_score == yearly_aci_base_score)
              aci_score = ((aci_base_requirements_completed) ? [aci_base_score + aci_bonus_score + aci_performance_bonus_score,100].min : 0)
            else
              temp_total = temp_advancing_care_info.to_f
              temp_base = 0
              temp_bonus = 0
              aci_base_requirements_completed = (temp_total >= yearly_aci_base_score)
              if aci_base_requirements_completed
                temp_base = yearly_aci_base_score
                temp_bonus = temp_total - yearly_aci_base_score
              end
              aci_base_score = temp_base
              aci_bonus_score = temp_bonus
              aci_performance_bonus_score = 0
              aci_score = temp_advancing_care_info
            end
            mips_scoreboard.advancing_care_info_base = (aci_base_requirements_completed ? aci_base_score : nil)
            mips_scoreboard.advancing_care_info_bonus = aci_bonus_score
            mips_scoreboard.advancing_care_info_performance_bonus = aci_performance_bonus_score
            mips_scoreboard.advancing_care_info = aci_score
            if !@selected_group.mips_quality_calc_flag and !ApplicationConfiguration.get_mips_quality_calc_flag
              mips_scoreboard.quality = temp_quality
            end
            mips_scoreboard.resource_use = temp_resource_use
            mips_scoreboard.cpia = temp_cpia

            mips_scoreboard.save
          end
        end
      end
    end
  end

  def get_medicare_projected_billing_value(department, attestation_requirement_fiscal_year, active_year)
    fiscal_year = AttestationRequirementFiscalYear.find_by_name(attestation_requirement_fiscal_year.medicare_billing_name)
    if !fiscal_year.nil?
      attestation_requirement_set_detail = AttestationRequirementSetDetail.AttestationRequirementSetDetails_By_Department_AttestationRequirementFiscalYearID_v2(department, fiscal_year)

      if !(attestation_requirement_set_detail.nil?) and (attestation_requirement_set_detail.attestation_requirement_status_id == 1)
        billing_detail = CmsEpActualBillingDetail.cms_ep_actual_billing_detail_by_npi_and_attestation_requirement_fiscal_year_id(department.npi, active_year)
        if !(billing_detail.nil?)
          billing_detail.total_medicare_allowed_amt.to_f
        else
          0
        end
      else
        0
      end
    else
      0
    end
  end

  def financial_summary_download_csv_file(file_name, title, group_name)
    x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, @selected_page_version_id)

    hide_no_billing = params["no_billing_#{x_year_attestation_method.id}"].nil?
    department_mips_scores = Department.Group_Departments_By_GroupID_ClinicID_EventID_XYearAttestationMethodID_UserDefinedFields_DepartmentOwnerID(@selected_group.id, @selected_attestation_clinic_id_portal, @selected_event_id, x_year_attestation_method.id, @multi_selected_user_defined_8_values, @billing_info_fiscal_year.id, @selected_department_owner_id, @selected_low_volume, x_year_attestation_method.attestation_method.has_clinic_rollup?, x_year_attestation_method.attestation_method.has_clinic_rollup?)
    x_fiscal_year_financial_method = XAttestationRequirementFiscalYearFinancialMethodType.find_by_attestation_requirement_fiscal_year_id_and_financial_method_type_id(@selected_attestation_requirement_fiscal_year_id, x_year_attestation_method.attestation_method.financial_method_type_id)
    target_set = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id, x_year_attestation_method.attestation_method_id)

    target_score = (target_set.nil? ? 0 : calculate_composite_score(target_set, x_year_attestation_method).to_f/100.0)

    file_name += '_' + x_year_attestation_method.attestation_method.name.downcase.tr(' ', '_')
    stream_csv(file_name + '_' + '' + @current_time.to_s + '.csv') do |csv|
      # Title of report
      csv << "Title of Report: #{title} - #{x_year_attestation_method.attestation_method.name}"
      csv << "Organization Name: #{group_name}"
      csv << ' '

      # header information
      header = []
      header << 'EC Name'
      header << 'Submission Method'
      header << 'TIN'
      header << 'NPI'
      header << 'Current MIPS Score'
      header << "#{@billing_info_fiscal_year.medicare_billing_name} Baseline Medicare"
      header << 'Regulatory Low'
      header << 'Current Results'
      header << 'Target Results'
      header << 'Regulatory High'
      header << 'Physician Compare Status'
      csv << header

      # detail information
      department_mips_scores.each do |department|
        unless hide_no_billing and department.total_medicare_payment_amt.nil?
          base_medicare = department.total_medicare_payment_amt.to_f
          regulatory_low = calculate_dollar_amount(0.0, base_medicare, x_fiscal_year_financial_method, @scaling_factor_base_selected.to_f, @scaling_factor_bonus_selected.to_f)
          current_results = calculate_financial_impact(department, x_year_attestation_method, x_fiscal_year_financial_method, @scaling_factor_base_selected.to_f, @scaling_factor_bonus_selected.to_f)
          target_results = [current_results, calculate_dollar_amount(target_score, base_medicare, x_fiscal_year_financial_method, @scaling_factor_base_selected.to_f, @scaling_factor_bonus_selected.to_f)].max
          regulatory_high = calculate_dollar_amount(1.0, base_medicare, x_fiscal_year_financial_method, @scaling_factor_base_selected.to_f, @scaling_factor_bonus_selected.to_f)

          display_results = []

          display_results << display_department_name1(department)
          display_results << department.submission_method_name
          display_results << display_clinic_TIN(department)
          display_results << display_NPI(department)
          display_results << calculate_composite_score(department, x_year_attestation_method)
          display_results << base_medicare
          display_results << regulatory_low
          display_results << current_results
          display_results << target_results
          display_results << regulatory_high
          display_results << department.physician_compare_status

          csv << display_results
        end
      end
    end
  end

  def aco_peer_review_download_csv_file(file_name, title, group_name, hide_aci_high = nil, hide_cqm_high = nil, hide_cpia_high = nil)
    selected_event = Event.find(@selected_event_id)
    file_name += "_#{selected_event.attestation_requirement_fiscal_year.name.downcase.tr(' ', '_')}_#{selected_event.attestation_requirement_stage.name.downcase.tr(' ', '_')}"
    stream_csv(file_name + '_' + '' + @current_time.to_s + '.csv') do |csv|
      # Title of report
      csv << "Title of Report: #{title} - #{selected_event.attestation_requirement_fiscal_year.name} - #{selected_event.attestation_requirement_stage.name}"
      csv << "Organization Name: #{group_name}"
      csv << ' '

      # header information
      aco_aci = aco_quality = aco_cpia = 0
      if @selected_attestation_method and @selected_attestation_method.has_group_rollup?
        aco_header = []
        3.times{aco_header << ''}
        if @selected_group.user_defined_label_8 != ""
          aco_header << ''
        end
        aco_header << 'ACO Scores'
        aco_header << aco_aci = number_with_precision(@x_group_year_attest_method.advancing_care_info, 1)
        aco_header << aco_quality = number_with_precision(@x_group_year_attest_method.quality, 1)
        aco_header << aco_cpia = number_with_precision(@x_group_year_attest_method.cpia, 1)
        aco_header << calculate_composite_score(@x_group_year_attest_method, @aco_x_year_attestation_method)
        aco_header << calculate_composite_score(@aco_target_set, @aco_x_year_attestation_method)
        2.times{aco_header << ''}
        csv << aco_header
      end
      header = []
      header << 'TIN Name'
      header << 'TIN'
      header << 'Reporting Entity Default'
      if @selected_group.user_defined_label_8 != ""
        header << @selected_group.user_defined_label_8.to_s+"(UDF)"
      end
      header << 'Assigned ECs'
      header << 'PI'
      header << 'CQM'
      header << 'CPIA'
      header << 'Actual MCS'
      header << 'Target MCS'
      header << 'Actual MIPS Adjustment'
      header << 'Target MIPS Adjustment'
      csv << header

      # detail information
      @tin_summary_attestation_clinics.each do |attestation_clinic|
        display_results = []

        x_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic.id, @selected_event_id)
        default_attestation_method_id = (x_clinic_event.nil? ? 0 : x_clinic_event.default_attestation_method_id).to_i
        if [-1, default_attestation_method_id].include? @selected_page_version_id
          display_use_manual_flag_checkboxes = (x_clinic_event and x_clinic_event.default_attestation_method and x_clinic_event.default_attestation_method.has_clinic_rollup?)
          aci_use_manual_fields_flag = (display_use_manual_flag_checkboxes ? x_clinic_event.aci_use_manual_fields_flag : false)
          quality_use_manual_fields_flag = (display_use_manual_flag_checkboxes ? x_clinic_event.quality_use_manual_fields_flag : false)
          display_results << attestation_clinic.name
          display_results << attestation_clinic.TIN
          display_results << ((x_clinic_event and x_clinic_event.default_attestation_method) ? x_clinic_event.default_attestation_method.name : 'Not Set')
          if @selected_group.user_defined_label_8 != ""
            display_results << attestation_clinic_display_user_defined_value(attestation_clinic.user_defined_value_8)
          end
          display_results << attestation_clinic.assigned_ec_count


          if x_clinic_event and x_clinic_event.default_attestation_method and x_clinic_event.default_attestation_method.has_clinic_rollup?
            attestation_clinic.advancing_care_info = attestation_clinic.manual_advancing_care_info if aci_use_manual_fields_flag
            attestation_clinic.quality = attestation_clinic.manual_quality if quality_use_manual_fields_flag

            # aci = remove_tailing_zeroes(attestation_clinic.advancing_care_info, 0)
            # cqm = remove_tailing_zeroes(attestation_clinic.quality, 1)
            # cpia = remove_tailing_zeroes(attestation_clinic.cpia, 0)
            aci = number_with_precision(attestation_clinic.advancing_care_info, 0)
            cqm = number_with_precision(attestation_clinic.quality, 1)
            cpia = number_with_precision(attestation_clinic.cpia, 0)
            x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, x_clinic_event.default_attestation_method_id)
            composite = calculate_composite_score(attestation_clinic, x_year_attestation_method)

            x_group_year_attest_method = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(attestation_clinic.group_id, @selected_attestation_requirement_fiscal_year_id, x_clinic_event.default_attestation_method_id)
            target_composite = calculate_composite_score(x_group_year_attest_method, x_year_attestation_method)

            include_low_volume = (x_clinic_event.nil? or x_clinic_event.default_attestation_method.nil? ? false : x_clinic_event.default_attestation_method.low_volume_included_flag)
            selected_low_volume = (include_low_volume ? -1 : 0)
          else
            # aci = remove_tailing_zeroes(attestation_clinic.indiv_avg_advancing_care_info, 0)
            # cqm = remove_tailing_zeroes(attestation_clinic.indiv_avg_quality, 1)
            # cpia = remove_tailing_zeroes(attestation_clinic.indiv_avg_cpia, 0)
            aci = number_with_precision(attestation_clinic.indiv_avg_advancing_care_info, 0)
            cqm = number_with_precision(attestation_clinic.indiv_avg_quality, 1)
            cpia = number_with_precision(attestation_clinic.indiv_avg_cpia, 0)
            attestation_clinic.advancing_care_info = attestation_clinic.indiv_avg_advancing_care_info
            attestation_clinic.quality = attestation_clinic.indiv_avg_quality
            attestation_clinic.cpia = attestation_clinic.indiv_avg_cpia
            x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(@selected_attestation_requirement_fiscal_year_id, default_attestation_method_id)
            composite = ((x_year_attestation_method.nil?) ? '' : calculate_composite_score(attestation_clinic, x_year_attestation_method))

            x_group_year_attest_method = XGroupYearAttestMethodTargetValueSet.find_by_group_id_and_attestation_requirement_fiscal_year_id_and_attestation_method_id(attestation_clinic.group_id, @selected_attestation_requirement_fiscal_year_id, default_attestation_method_id)
            target_composite = ((x_year_attestation_method.nil?) ? '' : calculate_composite_score(x_group_year_attest_method, x_year_attestation_method))

            include_low_volume = (x_clinic_event.nil? or x_clinic_event.default_attestation_method.nil? ? false : x_clinic_event.default_attestation_method.low_volume_included_flag)
            selected_low_volume = (include_low_volume ? -1 : 0)
          end

          display_results << aci

          display_results << cqm

          display_results << cpia

          aci_high = (aci.to_f >= aco_aci.to_f)
          cqm_high = (cqm.to_f >= aco_quality.to_f)
          cpia_high = (cpia.to_f >= aco_cpia.to_f)
          unless (hide_aci_high and aci_high) or (hide_cqm_high and cqm_high) or (hide_cpia_high and cpia_high)
            display_results << composite
            display_results << target_composite

            current_results_tin_total = target_results_tin_total = 0
            if x_year_attestation_method
              x_fiscal_year_financial_method = XAttestationRequirementFiscalYearFinancialMethodType.find_by_attestation_requirement_fiscal_year_id_and_financial_method_type_id(@selected_attestation_requirement_fiscal_year_id, x_year_attestation_method.attestation_method.financial_method_type_id)
              department_mips_scores = Department.Group_Departments_By_GroupID_ClinicID_EventID_XYearAttestationMethodID_UserDefinedFields_DepartmentOwnerID(@selected_group.id, attestation_clinic.id, @selected_event_id, x_year_attestation_method.id, @multi_selected_user_defined_8_values, @billing_info_fiscal_year.id, @selected_department_owner_id, selected_low_volume, x_year_attestation_method.attestation_method.has_clinic_rollup?, x_year_attestation_method.attestation_method.has_group_rollup?)
              department_mips_scores.each do |department|
                base_medicare = department.total_medicare_payment_amt.to_f
                current_results = calculate_financial_impact(department, x_year_attestation_method, x_fiscal_year_financial_method, @scaling_factor_base_selected.to_f, @scaling_factor_bonus_selected.to_f)
                target_results = [current_results, calculate_dollar_amount(target_composite.to_f/100.0, base_medicare, x_fiscal_year_financial_method, @scaling_factor_base_selected.to_f, @scaling_factor_bonus_selected.to_f)].max

                current_results_tin_total += current_results
                target_results_tin_total += target_results
              end
            end

            display_results << number_to_currency(current_results_tin_total, :precision => 0)
            display_results << number_to_currency(target_results_tin_total, :precision => 0)

            csv << display_results
          end
        end
      end
    end
  end

  def providers_without_ac_download_csv_file(file_name, title, group_name, download_department_records)
    stream_csv(file_name + '_' + '' + @current_time.to_s + '.csv') do |csv|
      # Title of report
      csv << "Title of Report: #{title}"
      csv << "Organization Name: #{group_name}"
      csv << ' '

      # header information
      header = []
      header << 'NPI'
      header << 'Name'
      header << 'Internal Clinic 1'
      header << 'Medicare Payment'
      header << 'Last Updated'
      header << 'PECOS Clinics'
      header << 'Task Status'
      header << 'Comment'
      csv << header

      # detail information
      download_department_records.each do |department|
        display_results = []

        display_results << department.npi

        display_results << display_department_name1(department)

        display_results << ((department.clinic) ? department.clinic.name : '')

        display_results << ((department.total_medicare_payment_amt.nil?) ? '' : number_to_currency(department.total_medicare_payment_amt, :precision => 0))

        display_results << ((department.pecos_updated_at) ? short_datetime_view(department.pecos_updated_at.in_time_zone('Central Time (US & Canada)')) : '')

        pecos_clinics = ''
        department.pecos_clinics_ordered.each do |pecos_clinic|
          pecos_clinics += pecos_clinic.name + "\n"
        end
        display_results << pecos_clinics

        display_results << display_department_task_status(department)

        display_results << department.description

        csv << display_results
      end
    end
  end

  def download_csv_file(download_records, file_name, title, group_name, group_id, group_type_id, department_label, selected_report_id)
    stream_csv(file_name + "_" + @current_time.to_s + ".csv") do |csv|
      # Title of report
      csv << "Title of Report: #{title}"
      csv << "Organization Name: #{group_name}"
      if selected_report_id == 13
        csv << "As-Of Date: #{@current_time.to_s}"
      end
      csv << " "

      # header information
      header = []
      case selected_report_id
        when 7
          header << department_label
          header << "Clinic 2"
          header << "Requirement ID"
          header << "Requirement Name"
          header << "Status Indicator"
          header << "Responsible Person(s)"
          header << "Target Value"
          header << "Current Value"
          header << "Numerator"
          header << "Denominator"
          header << "Date Range"
        # ScoreCard Report #
        when 13
          requirement_header = []
          5.times do requirement_header << '' end
          if group_type_id == 3
            6.times do requirement_header << '' end
          end
          requirement_header << 'Goals->'
          @scorecard_requirements = Requirement.Requirements_By_Fiscal_Year(@selected_group, @selected_requirement_id, @selected_criterion_id, @selected_requirement_type_id, @selected_attestation_requirement_fiscal_year_id)
          @scorecard_requirements.each do |requirement|
            goal = ' '
            if !requirement.target_measure.blank?
              goal = requirement.target_measure.to_s + '%'
            end
            requirement_header << goal
          end
          csv << requirement_header

          header << 'Attestation Clinic'
          header << 'Internal Clinic 1'
          header << 'Internal Clinic 2'
          header << 'Stage'
          header << 'Year'
          header << 'EP'
          if group_type_id == 3
            header << 'Entity Type'
            header << 'Promoting Interoperability'
            header << 'Quality'
            header << 'Resource Use'
            header << 'CPIA'
            header << 'Composite Score'
          end
          @scorecard_requirements.each do |requirement|
            requirement_event = Event.find(requirement.event_id)
            header << requirement_event.attestation_requirement_stage.name.to_s+': '+requirement.requirement_identifier.to_s+' - '+requirement.short_name.to_s
          end
        ####################
      end
      csv << header

      # detail information
      for download_records in download_records
        display_manual_flag_override_indicator = ""
        display_denominator_not_set_indicator = ""
        display_master_manual_flag_override_indicator = ""
        display_department_requirement_exclusion_flag_indicator = ""
        #| ScoreCard Report           |#
        if selected_report_id != 11 and selected_report_id != 12 and selected_report_id != 13 and ((selected_report_id != 6) and download_records.manual_override_requirement_status_flag > 0)
          display_master_manual_flag_override_indicator = "-m"
        end

        case selected_report_id
          when 7
            display_results = []
            department_name = display_department_name1(download_records.x_department_criterion_status.department)
            if group_type_id == 3 and !download_records.x_department_criterion_status.department.eligible_professional_type.nil?
              department_name += ", "+download_records.x_department_criterion_status.department.eligible_professional_type.name
            end
            display_results << department_name
            display_results << ((download_records.x_department_criterion_status.department.attestation_clinic2.nil?) ? 'Not Set' : download_records.x_department_criterion_status.department.attestation_clinic2.name)
            display_results << download_records.x_group_requirement.requirement.requirement_identifier
            requirement_name = download_records.x_group_requirement.requirement.name
            display_results << requirement_name
            display_results << download_records.criterion_status.display_name.to_s+display_new_review_flag(download_records.new_review_indicator_flag).to_s+display_master_manual_flag_override_indicator.to_s
            responsible_person_value = ""
            if !download_records.x_department_criterion_status.department.user.nil?
              responsible_person_value = download_records.x_department_criterion_status.department.user.get_full_name
            end
            if !download_records.x_department_criterion_status.department.department_owner_alt.nil?
              responsible_person_value += " and "+download_records.x_department_criterion_status.department.department_owner_alt.get_full_name.to_s
            end
            display_results << responsible_person_value

            target_measure_value = ""
            if download_records.x_group_requirement.requirement.requirement_measure_type_id == 3
              target_measure_value = display_current_yesno_measure_results(download_records.x_group_requirement.requirement.target_measure)
            else
              if download_records.x_group_requirement.requirement.target_measure.to_f > 0
                target_measure_value = "> "
              end
              target_measure_value = target_measure_value.to_s+download_records.x_group_requirement.requirement.target_measure.to_s+"%" # download_records.x_group_requirement.requirement.target_measure
            end

            display_results << target_measure_value

            current_measure_value = ""
            if download_records.x_group_requirement.requirement.requirement_measure_type_id == 3
              current_measure_value = display_current_yesno_measure_results(download_records.current_measure)
            else
              if download_records.denominator.to_f > 0
                current_measure_value = ((download_records.numerator.to_f/download_records.denominator.to_f)*100).to_s+"%"
              else
                current_measure_value = "Not Set" #download_records.current_measure
              end
            end

            display_results << current_measure_value

            numerator_value = ""
            if download_records.x_group_requirement.requirement.requirement_measure_type_id == 3
              numerator_value = "N/A"
            else
              if !download_records.numerator.nil?
                numerator_value = download_records.numerator.to_i
              else
                numerator_value = 0
              end
            end

            display_results << numerator_value

            denominator_value = ""
            if download_records.x_group_requirement.requirement.requirement_measure_type_id == 3
              denominator_value = "N/A"
            else
              if !download_records.denominator.nil?
                denominator_value = download_records.denominator.to_i
              else
                denominator_value = 0
              end
            end

            display_results << denominator_value

            date_range = ""
            if download_records.x_group_requirement.requirement.requirement_measure_type_id == 3
              date_range = "N/A"
            else
              if download_records.current_measure_start_date.nil? and download_records.current_measure_end_date.nil?
                date_range = "Not Set"
              elsif download_records.current_measure_start_date.nil?
                date_range = "Not Set to "+short_date_view(download_records.current_measure_end_date).to_s
              elsif download_records.current_measure_end_date.nil?
                date_range = short_date_view(download_records.current_measure_start_date).to_s+" to Not Set"
              else
                date_range = short_date_view(download_records.current_measure_start_date).to_s+" to "+short_date_view(download_records.current_measure_end_date).to_s
              end

            end

            display_results << date_range

          when 13
            display_results = []

            display_results << download_records.attestation_clinic_name

            display_results << download_records.clinic1_name
            display_results << download_records.clinic2_name

            arsd = AttestationRequirementSetDetail.find(download_records.x1_id)
            display_results << arsd.event.attestation_requirement_stage.name
            display_results << (arsd.attestation_requirement_reporting_period_id.nil? ? 'N/A' : arsd.attestation_requirement_reporting_period.name)

            cur_department = Department.find(download_records.id)
            department_name = display_department_name1(cur_department)
            if group_type_id == 3 and !cur_department.eligible_professional_type.nil?
              department_name += ", "+cur_department.eligible_professional_type.name
            end
            display_results << department_name
            if group_type_id == 3
              attestation_method_name = ''
              advancing_care_info = ''
              quality = ''
              resource_use = ''
              cpia = ''
              composite_score = ''
              if arsd.x_year_attestation_method
                attestation_method_name = arsd.x_year_attestation_method.attestation_method.name
                if arsd.x_year_attestation_method.attestation_method.has_clinic_rollup?
                  download_records.advancing_care_info = download_records.group_advancing_care_info
                  download_records.quality = download_records.group_quality
                  download_records.resource_use = download_records.group_resource_use
                  download_records.cpia = download_records.group_cpia
                end

                advancing_care_info = download_records.advancing_care_info
                quality = download_records.quality
                resource_use = download_records.resource_use
                cpia = download_records.cpia
                composite_score = calculate_composite_score(download_records, arsd.x_year_attestation_method)
              end
              display_results << attestation_method_name
              display_results << advancing_care_info
              display_results << quality
              display_results << resource_use
              display_results << cpia
              display_results << composite_score
            end
            # logger.info "physician id1"+download_records.id.to_s
            @scorecard_requirements = Requirement.Requirements_Outer_Join_By_Fiscal_Year(download_records.id, @selected_group, download_records.attestation_clinic_id, @selected_requirement_id, @selected_criterion_id, @selected_requirement_type_id, @selected_attestation_requirement_fiscal_year_id)
            @scorecard_requirements.each do |requirement|
              #logger.info "physician id3"+download_records.id.to_s
              current_measure_value = ' '
              if requirement.stage_id.to_i != arsd.event.attestation_requirement_stage_id.to_i
                current_measure_value = ""
              elsif requirement.requirement_measure_type_id == 3
                if !requirement.current_measure.nil?
                  current_measure_value = display_current_yesno_measure_results(requirement.current_measure)
                else
                  current_measure_value = "N/R"
                end
              else
                if !requirement.denominator.nil? and requirement.denominator.to_f > 0
                  current_measure_value = ((requirement.numerator.to_f/requirement.denominator.to_f)*100).to_s+"%"
                  #current_measure_value = requirement.numerator.to_s+"/"+requirement.denominator.to_s
                else
                  current_measure_value = "N/R"
                end
              end
              #logger.info "value"+current_measure_value.to_s
              display_results << current_measure_value
            end
          ####################
        end
        csv << display_results
      end
    end
  end

  def display_current_yesno_measure_results(current_measure_results)
    case current_measure_results.to_i
      when 1
        current_measure_results_name = "Yes"
      else
        current_measure_results_name = "No"
    end

    return current_measure_results_name
  end

  def display_report_requirement_short_name(requirement_short_name, requirement_name, max_length = 10)
    display_requirement_name = "Error:  Requirement Name not defined"
    if !requirement_short_name.nil? and requirement_short_name.strip.size > 0
      display_requirement_name = requirement_short_name
    elsif !requirement_name.nil? and requirement_name.strip.size > 0
      display_requirement_name = requirement_name.to_s[0..max_length]+"... [Short Ver. Not Defined]"
    end
  end

  def short_date_view(date_value)
    if !date_value.nil? and date_value != 0
      return date_value.strftime("%m/%d/%Y")
    else
      return "&nbsp;"
    end
  end

  def short_datetime_view(date_value)
    if !date_value.nil? and date_value != 0
      return date_value.strftime("%m/%d/%Y %H:%M:%S")
    else
      return "&nbsp;"
    end
  end

  def display_department_task_status(department)
    if department.department_task_status.nil?
      'None'
    else
      department.department_task_status.name
    end
  end

  def calculate_base_adjustment_percent(score, x_fiscal_year_financial_method)
    adjustment_percent = 0
    unless x_fiscal_year_financial_method.nil?
      base_threshold = x_fiscal_year_financial_method.mips_financial_base_threshold_perc.to_f/100.0
      negative_threshold = base_threshold*0.25
      annual_adjust_perc = x_fiscal_year_financial_method.mips_base_adjustment_percent.to_f/100.0
      if x_fiscal_year_financial_method.is_apm_flat_method? or x_fiscal_year_financial_method.is_non_participating_method?
        adjustment_percent = annual_adjust_perc
      elsif x_fiscal_year_financial_method.is_mips_method?
        if score < negative_threshold
          adjustment_percent = annual_adjust_perc * -1
        elsif score < base_threshold
          adjustment_percent = ((score - base_threshold)/(base_threshold - negative_threshold))*annual_adjust_perc
        else
          adjustment_percent = ((score - base_threshold)/(1 - base_threshold))*annual_adjust_perc
        end
      end
    end
    adjustment_percent
  end

  def calculate_bonus_adjustment_percent(score, x_fiscal_year_financial_method)
    adjustment_percent = 0
    unless x_fiscal_year_financial_method.nil?
      if x_fiscal_year_financial_method.is_apm_flat_method? or x_fiscal_year_financial_method.is_non_participating_method?
        adjustment_percent = 0
      elsif x_fiscal_year_financial_method.is_mips_method?
        bonus_threshold = x_fiscal_year_financial_method.mips_financial_bonus_threshold_perc.to_f/100.0
        bonus_adjustment_perc_lower = x_fiscal_year_financial_method.mips_bonus_adjustment_percent_lower_limit.to_f/100.0
        bonus_adjustment_perc_upper = x_fiscal_year_financial_method.mips_bonus_adjustment_percent_upper_limit.to_f/100.0

        bonus_adjust_perc_base = bonus_adjustment_perc_lower
        bonus_adjust_perc = bonus_adjustment_perc_upper - bonus_adjustment_perc_lower
        if score < bonus_threshold
          adjustment_percent = 0
        else
          adjustment_percent = ((score - bonus_threshold)/(1 - bonus_threshold))*bonus_adjust_perc + bonus_adjust_perc_base
        end
      end
    end
    adjustment_percent
  end

  def calculate_dollar_amount(score, medicare_amt, x_fiscal_year_financial_method, scaling_factor_base = 1.0, scaling_factor_bonus = 1.0)
    total = 0
    unless x_fiscal_year_financial_method.nil?
      base_adjust_perc = calculate_base_adjustment_percent(score, x_fiscal_year_financial_method)
      bonus_adjust_perc = calculate_bonus_adjustment_percent(score, x_fiscal_year_financial_method)

      base_money = medicare_amt*base_adjust_perc
      base_money *= scaling_factor_base if base_money > 0 and !x_fiscal_year_financial_method.is_apm_flat_method?

      bonus_money = medicare_amt*bonus_adjust_perc*scaling_factor_bonus

      total = base_money + bonus_money
    end
    total
  end

  def calculate_composite_score(entity, x_year_attestation_method)
    # Weights
    # 25% advancing_care_info
    # 50% quality
    # 10% resource_use
    # 15% cpia
    aci_weight = x_year_attestation_method.mips_aci_weight_perc.to_f / 100.0
    quality_weight = x_year_attestation_method.mips_quality_weight_perc.to_f / 100.0
    resource_weight = x_year_attestation_method.mips_resource_weight_perc.to_f / 100.0
    cpia_weight = x_year_attestation_method.mips_cpia_weight_perc.to_f / 100.0
    score = 0
    unless entity.advancing_care_info.nil? and entity.quality.nil? and entity.resource_use.nil? and entity.cpia.nil?
      score = entity.advancing_care_info.to_f*aci_weight + entity.quality.to_f*quality_weight + entity.resource_use.to_f*resource_weight + entity.cpia.to_f*cpia_weight
      score = score.round
    end
    score
  end

  def calculate_financial_impact(entity, x_year_attestation_method, x_fiscal_year_financial_method, scaling_factor_base = 1.0, scaling_factor_bonus = 1.0)
    total = 0
    unless (calculated_score = calculate_composite_score(entity, x_year_attestation_method)).nil? || x_fiscal_year_financial_method.nil?
      mips_composite_score = calculated_score.to_f/100.0
      medicare_amount = entity.total_medicare_payment_amt.to_f

      total = calculate_dollar_amount(mips_composite_score, medicare_amount, x_fiscal_year_financial_method, scaling_factor_base, scaling_factor_bonus)
    end
    total
  end

  def display_department_name1(department)
    default_department_name = 'Not Assigned'
    if !department.nil? and !department.name.nil?
      if department.group.group_type_id == 3 and !department.first_name.nil? and department.first_name.size > 0
        default_department_name = department.name+', '+department.first_name
      else
        default_department_name = department.name
      end
    end
    return default_department_name
  end

  def display_clinic_TIN(department)
    department_clinic_tin = 'Not Set'
    if department.attestation_clinic
      department_clinic_tin = department.attestation_clinic.TIN
    end
    department_clinic_tin
  end

  def display_NPI(department)
    default_department_NPI = "Not Set"
    if !department.nil? and !department.npi.nil? and department.npi.size > 0
      default_department_NPI = department.npi
    end
    return default_department_NPI
  end

  def attestation_clinic_display_user_defined_value(attestation_clinic_user_defined_value)
    default_attestation_clinic_user_defined_label = 'Not Set'
    if !attestation_clinic_user_defined_value.nil?
      default_attestation_clinic_user_defined_label = attestation_clinic_user_defined_value.user_defined_value
    end
    return default_attestation_clinic_user_defined_label
  end

end
