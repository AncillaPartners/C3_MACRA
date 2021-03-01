class ApplicationController < ActionController::Base
  before_action :authorize, :page_initializer

  # The expiration time.
  MAX_SESSION_TIME = 60 * 60


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => 'aa1cfae3452a164f9ed2634d319a8631'


  def page_initializer
    @current_subdomain = request.subdomains.first
    @detail2_div = session[:detail2_div]

    @attestation_clinic_filter_controllers = ['home', 'financial_management', 'report', 'batch_attestation']
    @attestation_clinic_filter_controller_actions = ['mass_maintenance-index', 'mass_maintenance-view_attest_ep',
                                                     'mass_maintenance-quick_entry', 'mass_maintenance-add_attestation_history',
                                                     'aci-index', 'aci-aci_summary_report', 'aci-aci_detail_report', 'aci-aci_individual_detail_report',
                                                     'aci-aco_11_detail_report', 'aci-aco_11_individual_detail_report', 'quality-index','quality-cqm_summary_report',
                                                     'quality-cqm_detail_report', 'quality-cqm_selector', 'quality-ec_comparison_tool', 'quality-cqm_date_range_report',
                                                     'cpia-index', 'cpia-physician_assign', 'cpia-cpia_group_summary']

    @current_time = Time.zone.now #user_time_zone_now #Time.zone.now

    # NORMAL MAIN TABS

    # Only C3 master admins see these tabs
    @global_cqm_template_tab = 'Global CQM Templates'
    @global_cqm_template_label = @global_cqm_template_tab

    @attestation_method_tab = 'Entity Types'
    @attestation_method_label = @attestation_method_tab

    @upload_tab = 'Uploads'
    @upload_label = @upload_tab

    @batch_history_tab = 'Batch Histories'
    @batch_history_label = @batch_history_tab

    @splash_page_tab = 'Splash Pages'
    @splash_page_label = @splash_page_tab

    # Only hospitals and physician groups see this tab
    if @selected_mum_program_view == 1 # MUM
      @home_tab = 'Home'
      @data_label = @home_tab
    elsif @selected_mum_program_view == 2 # MIPS
      @home_tab = 'Financial'
      @data_label = @home_tab
    end

    # Everyone sees these tabs
    @compliance_event_tab = "Requirement Set" # replaced on 1/14/2013"Compliance Events"
    @compliance_event_label = @compliance_event_tab

    if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
      @requirement_tab = "Requirements"
      @requirement_label = "Requirements View"
    else
      @requirement_tab = "New & Updated Requirements"
      @requirement_label = "New & Updated Requirements View"
    end

    # Only hospitals and physician groups see these tabs
    if @selected_mum_program_view == 1 # MUM
      @group_requirement_tab = 'Requirements'
      @group_requirement_label = 'Requirements View'
    elsif @selected_mum_program_view == 2 # MIPS
      @group_requirement_tab = 'Manage Existing Requirements'
      @group_requirement_label = 'Requirements View'
    end

    @department_management_console_label = "Management Console"
    @department_management_console_tab = @department_management_console_label


    @plan_manager_console_tab = "Action Items"
    @plan_manager_console_label = @plan_manager_console_tab
    @has_active_action_items = ActionItem.any_incomplete_by_group_id?(@selected_group_id)

    @financial_management_tab = "Financials"
    @financial_management_label = @financial_management_tab

    @quick_data_entry_tab = "Quick Entry"
    @quick_data_entry_label = @quick_data_entry_tab
    @mass_data_entry_tab = "Mass Update"
    @mass_data_entry_label = @mass_data_entry_tab
    @add_attestation_history_tab = "Mass Add Attestation History"
    @add_attestation_history_label = @add_attestation_history_tab
    @attest_ep_tab = "Attest An EP"
    @attest_ep_label = @attest_ep_tab
    @mass_actions_tab = "Mass Actions"
    @mass_actions_label = @mass_actions_tab
    @pecos_reconciliation_tab = "PECOS Reconciliation"
    @pecos_reconciliation_label = @pecos_reconciliation_tab
    @tin_quick_data_entry_tab = "TIN Quick Entry"
    @tin_quick_data_entry_label = @tin_quick_data_entry_tab
    @interfaces_tab = "Interfaces"
    @interfaces_label = @interfaces_tab
    @batch_attestation_tab = "Attestation Batch Listing"
    @batch_attestation_label = @batch_attestation_tab
    @group_attestation_requirement_template_tab = "Attestation Requirement Templates"
    @group_attestation_requirement_template_label = @group_attestation_requirement_template_tab

    @attestation_clinic_tab = "Attestation Clinics"
    @attestation_clinic_label = @attestation_clinic_tab

    @clinic_tab = "Internal Clinics"
    @clinic_label = @clinic_tab

    @pecos_clinic_tab = "PECOS Clinics"
    @pecos_clinic_label = @pecos_clinic_tab

    # REPORTS TABS
    @reports_tab = "Reports"
    @reports_label = @reports_tab

    #DISCUSSION BOARD TABS
    @discussion_board_tab = "Community of Practice"
    @discussion_board_label = @discussion_board_tab

    # ADMIN TABS
    @health_system_tab = "Health Systems"
    @health_system_label = @health_system_tab

    if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
      @group_tab = "Groups"
    elsif @selected_group.group_type_id == 2
      @group_tab = "Hospitals"
    elsif @selected_group.group_type_id == 3
      @group_tab = "Ambulatory"
    end
    @group_label = @group_tab

    @user_tab = "Users"
    @user_label = @user_tab

    if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
      @department_tab = "Level 3"
    elsif @selected_group.group_type_id == 2
      @department_tab = "Departments"
    elsif @selected_group.group_type_id == 3
      @department_tab = "Physicians"
    end
    @department_label = @department_tab

    @ep_type_tab = "EP Types"
    @ep_type_label = "Eligible Professional Types"

    @specialty_tab = "Specialties"
    @specialty_label = @specialty_tab

    @meeting_status_tab = "Meeting Statuses"
    @meeting_status_label = @meeting_status_tab

    @group_actual_payment_tab = "Payments"
    @group_actual_payment_label = @group_actual_payment_tab

    @group_user_defined_values_tab = "User Defined Values"
    @group_user_defined_values_label = @group_user_defined_values_tab

    @criterion_tab = "Category"
    @criterion_label = @criterion_tab

    @sub_criterion_tab = "Sub Category"
    @sub_criterion_label = @sub_criterion_tab

    @technology_tab = "Technology"
    @technology_vendor_label = "Technology Vendors"
    @technology_product_label = "Technology Products"
    @technology_module_label = "Technology Modules"

    @messaging_label = @messaging_tab = "Messaging"

    @cms_update_label = @cms_update_tab = "CMS Update"

    @public_files_label = @public_files_tab = "Public Files"

    # UPPER NAVIGATION LINKS
    @help_tab = "MACRA Guru"
    @about_tab = "About"
    @normal_tab = "Normal"
    @admin_tab = "Admin"
    @edit_tab = "Data"
    @log_out_tab = "Log Out"

    @controller_action_name = controller_name.to_s+"-"+action_name.to_s
    @controller_name = controller_name.to_s
    @action_name = action_name.to_s
    @action_name_mm = action_name.to_s+"-"
    @action_name_mm = @action_name_mm.sub('-','')
    @current_main_nav = 1 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    @mum_support_email = "mumsupport@ancillapartners.com"

    # MIPS TABS
    if @selected_mum_program_view == 2
      @aci_tab = 'PI'
      @quality_tab = 'Quality'
      # @resource_tab = 'Resource'
      @cpia_tab = 'CPIA'
      # @caphs_survey_tab = 'CAPHS Survey'
      @submission_tab = 'Submission'
      case controller_name
        when 'aci'
          @aci_tab = "<p class='nav_selected'>#{@aci_tab}</p>"
        when 'quality'
          @quality_tab = "<p class='nav_selected'>#{@quality_tab}</p>"
        when 'cpia'
          @cpia_tab = "<p class='nav_selected'>#{@cpia_tab}</p>"
        when 'submission'
          @submission_tab = "<p class='nav_selected'>#{@submission_tab}</p>"
      end

      @aco_quality_data_entry_tab = "ACO Quality Measure Data Entry"
      @aco_quality_data_entry_label = @aco_quality_data_entry_tab
    end

    if (controller_name == "home" or controller_name == "department_management_console")
      @home_tab = "<p class='nav_selected'>#{@home_tab}</p>"
      @current_main_nav = 1 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "group_requirement")
      if @selected_mum_program_view == 1
        @group_requirement_tab = "<p class='nav_selected'>#{@group_requirement_tab}</p>"
        @current_main_nav = 6 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      elsif @selected_mum_program_view == 2
        @admin_tab = "<p class='nav_selected'>#{@admin_tab}</p>"
        @group_requirement_tab = "<p class='subnav_selected'>#{@group_requirement_tab}</p>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
    end

    if (controller_name == "financial_management")
      @financial_management_tab = "<p class='nav_selected'>#{@financial_management_tab}</p>"
      @current_main_nav = 1 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "plan_manager_console")
      @plan_manager_console_tab = "<p class='nav_selected'>#{@plan_manager_console_tab}</p>"
      @current_main_nav = 4 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "action_plan")
      @action_plan_tab = "<p class='nav_selected'>#{@action_plan_tab}</p>"
      @current_main_nav = 4 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "utilities" && action_name == "help")
      @help_tab = "<p class='nav_selected'>#{@help_tab}</p>"
    end
    if (controller_name == "utilities" && action_name == "about")
      @about_tab = "<p class='nav_selected'>#{@about_tab}</p>"
    end
    if (controller_name == "utilities" &&  action_name == "edit_my_account")
      @my_account_tab = "<p class='nav_selected'>#{@my_account_tab}</p>"
    end

    if (controller_name == "mass_maintenance")
      @edit_tab = "<p class='nav_selected'>#{@edit_tab}</p>"
      if (action_name == "quick_entry")
        @quick_data_entry_tab = "<p class='subnav_selected'>#{@quick_data_entry_tab}</p>"
      elsif (action_name == "aco_quality_data_entry")
        @aco_quality_data_entry_tab = "<p class='subnav_selected'>#{@aco_quality_data_entry_tab}</p>"
      elsif(action_name == "index")
        @mass_data_entry_tab = "<p class='subnav_selected'>#{@mass_data_entry_tab}</p>"
      elsif(action_name == "add_attestation_history")
        @add_attestation_history_tab = "<p class='subnav_selected'>#{@add_attestation_history_tab}</p>"
      elsif(action_name == "actions")
        @mass_actions_tab = "<p class='subnav_selected'>#{@mass_actions_tab}</p>"
      elsif(action_name == "pecos_reconciliation")
        @pecos_reconciliation_tab = "<p class='subnav_selected'>#{@pecos_reconciliation_tab}</p>"
      elsif(action_name == "tin_quick_entry")
        @tin_quick_data_entry_tab = "<p class='subnav_selected'>#{@tin_quick_data_entry_tab}</p>"
      elsif(action_name == "interfaces")
        @interfaces_tab = "<p class='subnav_selected'>#{@interfaces_tab}</p>"
      elsif(action_name == "view_attest_ep" || action_name == "edit_attest_ep")
        @attest_ep_tab = "<p class='subnav_selected'>#{@attest_ep_tab}</p>"
      else
        @quick_data_entry_tab = "<p class='subnav_selected'>#{@quick_data_entry_tab}</p>"
      end
      @current_main_nav = 2 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end

    if (controller_name == "batch_attestation")
      @edit_tab = "<p class='nav_selected'>#{@edit_tab}</p>"
      @batch_attestation_tab = "<p class='subnav_selected'>#{@batch_attestation_tab}</p>"
      @current_main_nav = 2 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end

    if (controller_name == "report")
      @selected_report_id = (params[:selected_report_id] || 8).to_i
      @reports_tab = "<p class='nav_selected'>#{@reports_tab}</p>"
      @current_main_nav = 5 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end

    if (controller_name == "event") or (controller_name == "requirement") or (controller_name == "user" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "group" && @user.user_type_id.to_i == 1 ) or (controller_name == "department" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "attestation_clinic" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "clinic" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "pecos_clinic" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "health_system" && @user.user_type_id.to_i == 1 ) or (controller_name == "group_actual_payment" && @user.user_type_id.to_i == 1) or
        (controller_name == "group_attestation_requirement_template" && @user.user_type_id.to_i == 1) or
        (controller_name == "criterion" && @user.user_type_id.to_i == 1 ) or (controller_name == "sub_criterion" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "eligible_professional_type" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "specialty" && @user.user_type_id.to_i == 1 ) or (controller_name == "meeting_status" && @user.user_type_id.to_i == 1 )
      (controller_name == "group_user_defined_value" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "cms_update" && @user.user_type_id.to_i == 1 ) or  (controller_name == "messaging" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "public_files" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "global_cqm_template" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "attestation_method" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "upload" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "batch_history" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "splash_page" && @user.user_type_id.to_i == 1 ) or
          ((controller_name == "technology_vendor" || controller_name == "technology_product" || controller_name == "technology_module") && @user.user_type_id.to_i == 1 )
      @admin_tab = "<p class='nav_selected'>#{@admin_tab}</p>"
      if (controller_name == "group_attestation_requirement_template")
        @group_attestation_requirement_template_tab = "<span class='subnav_selected'>#{@group_attestation_requirement_template_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "event")
        @compliance_event_tab = "<span class='subnav_selected'>#{@compliance_event_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "requirement")
        @requirement_tab = "<span class='subnav_selected'>#{@requirement_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "user" && @user.user_type_id.to_i == 1 )
        @user_tab = "<span class='subnav_selected'>#{@user_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "group" && @user.user_type_id.to_i == 1 )
        @group_tab = "<span class='subnav_selected'>#{@group_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
        @current_main_controller = 2
      end
      if (controller_name == "department" && @user.user_type_id.to_i == 1 )
        @department_tab = "<span class='subnav_selected'>#{@department_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
        @current_main_controller = 5
      end
      if (controller_name == "attestation_clinic" && @user.user_type_id.to_i == 1 )
        @attestation_clinic_tab = "<span class='subnav_selected'>#{@attestation_clinic_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
        @current_main_controller = 4
      end
      if (controller_name == "clinic" && @user.user_type_id.to_i == 1 )
        @clinic_tab = "<span class='subnav_selected'>#{@clinic_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "pecos_clinic" && @user.user_type_id.to_i == 1 )
        @pecos_clinic_tab = "<span class='subnav_selected'>#{@pecos_clinic_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "health_system" && @user.user_type_id.to_i == 1 )
        @health_system_tab = "<span class='subnav_selected'>#{@health_system_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "group_actual_payment" && @user.user_type_id.to_i == 1)
        @group_actual_payment_tab = "<span class='subnav_selected'>#{@group_actual_payment_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "group_user_defined_value" && @user.user_type_id.to_i == 1 )
        @group_user_defined_values_tab = "<span class='subnav_selected'>#{@group_user_defined_values_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "criterion" && @user.user_type_id.to_i == 1 )
        @criterion_tab = "<span class='subnav_selected'>#{@criterion_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "sub_criterion" && @user.user_type_id.to_i == 1 )
        @sub_criterion_tab = "<span class='subnav_selected'>#{@sub_criterion_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "eligible_professional_type" && @user.user_type_id.to_i == 1 )
        @ep_type_tab = "<span class='subnav_selected'>#{@ep_type_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "specialty" && @user.user_type_id.to_i == 1 )
        @specialty_tab = "<span class='subnav_selected'>#{@specialty_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "meeting_status" && @user.user_type_id.to_i == 1 )
        @meeting_status_tab = "<span class='subnav_selected'>#{@meeting_status_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if ((controller_name == "technology_vendor" || controller_name == "technology_product" || controller_name == "technology_module") && @user.user_type_id.to_i == 1 )
        @technology_tab = "<span class='subnav_selected'>#{@technology_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "messaging" && @user.user_type_id.to_i == 1 )
        @messaging_tab = "<span class='subnav_selected'>#{@messaging_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "cms_update" && @user.user_type_id.to_i == 1 )
        @cms_update_tab = "<span class='subnav_selected'>#{@cms_update_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "public_files" && @user.user_type_id.to_i == 1 )
        @public_files_tab = "<span class='subnav_selected'>#{@public_files_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "global_cqm_template" && @user.user_type_id.to_i == 1 )
        @global_cqm_template_tab = "<span class='subnav_selected'>#{@global_cqm_template_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "attestation_method" && @user.user_type_id.to_i == 1 )
        @attestation_method_tab = "<span class='subnav_selected'>#{@attestation_method_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "upload" && @user.user_type_id.to_i == 1 )
        @upload_tab = "<span class='subnav_selected'>#{@upload_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "batch_history" && @user.user_type_id.to_i == 1 )
        @batch_history_tab = "<span class='subnav_selected'>#{@batch_history_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == 'splash_page' && @user.user_type_id.to_i == 1 )
        @splash_page_tab = "<span class='subnav_selected'>#{@splash_page_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
    end
    if (controller_name == "global_cqm_template" && @user.user_type_id.to_i == 1 )
      @global_cqm_template_tab = "<span class='subnav_selected'>#{@global_cqm_template_tab}</span>"
      @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    @new_group_requirements = Requirement.new_group_requirements(@selected_group.id)
  end

  def authorize
    prepare_session
    if !session[:user_id].nil? && User.find_by_id(session[:user_id]) && User.find_by_id(session[:user_id]).active?
      #begin
      @user = User.find(session[:user_id].to_i)
      if session[:group_id].nil?
        @default_group = XUserGroup.find_by_user_id_and_status_and_active(@user.id, 1, 1)
        session[:group_id] = @default_group.group_id
      end
      if session[:attestation_clinic_id_portal].nil? || (params[:selected_group_id] && session[:group_id] != params[:selected_group_id].to_i)
        session[:attestation_clinic_id_portal] = -1
      end
      @default_group_id = session[:group_id]
      @selected_group_id = (params[:selected_group_id] || @default_group_id).to_i
      session[:group_id] = @selected_group_id
      @selected_user_group = XUserGroup.find_by_user_id(@user.id)
      @selected_groups = Group.GetFilteredGroupsBySecurity_Level(@user, @selected_user_group, @selected_user_group.group.health_system_id)
      @selected_group = Group.find(@selected_group_id)

      # if @selected_group.x_group_mum_programs.empty?
      #   default_group_mum_program = XGroupMumProgram.new
      #   default_group_mum_program.group_id = @selected_group.id
      #   default_group_mum_program.mum_program_id = 1
      #   default_group_mum_program.active = true
      #   group_mips_mum_program = XGroupMumProgram.new
      #   group_mips_mum_program.group_id = @selected_group.id
      #   group_mips_mum_program.mum_program_id = 2
      #   default_group_mum_program.save
      #   group_mips_mum_program.save
      # end
      if session[:mum_program_view].nil?
        session[:mum_program_view] = 2
      end
      if @default_group_id != @selected_group_id
        redirect_to root_path
      end
      if @default_group_id != @selected_group_id
        params[:selected_attestation_clinic_id_portal] = -1
      end
      @default_mum_program_view = session[:mum_program_view]
      @selected_mum_program_view = (params[:selected_mum_program_view] || @default_mum_program_view).to_i
      session[:mum_program_view] = @selected_mum_program_view

      @default_attestation_clinic_id_portal = session[:attestation_clinic_id_portal]
      @selected_attestation_clinic_id_portal = (params[:selected_attestation_clinic_id_portal] || @default_attestation_clinic_id_portal).to_i
      session[:attestation_clinic_id_portal] = @selected_attestation_clinic_id_portal

      @accepted_security_levels = [4]
      @accepted_user_types = [1, 2]
      if @accepted_security_levels.include? @user.security_level_id and @accepted_user_types.include? @user.user_type_id
        @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentOwnerID_And_DepartmentCount_for_select_in_form(@selected_group.id, @user.id)
      else
        @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentCount_for_select_in_form(@selected_group.id)
      end
      if @selected_attestation_clinics_portal.size == 1
        @selected_attestation_clinic_id_portal = @selected_attestation_clinics_portal.first[1]
      end

      @default_event_id = session[:event_id]
      @default_attestation_requirement_fiscal_year_id = session[:attestation_requirement_fiscal_year_id]
      @default_attestation_requirement_stage_id = session[:attestation_requirement_stage_id] || @selected_group.default_attestation_requirement_stage_id || -1

      @default_attestation_requirement_type_id = session[:attestation_requirement_type_id]
      @default_attestation_requirement_fiscal_year = {}
      if(@selected_group.group_type_id != 1 and @selected_group.group_type_id != 4)
        @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
        if @default_attestation_requirement_fiscal_year_id.nil? or @default_attestation_requirement_fiscal_year_id <= 0
          if @default_attestation_requirement_fiscal_year.nil?
            @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
          end
          @default_attestation_requirement_fiscal_year_id = @default_attestation_requirement_fiscal_year.id.to_i
        end
      end
      if(@default_group_id != @selected_group_id) or ((params[:selected_event_id].nil? or params[:selected_event_id] == -1) and (session[:event_id].nil? or session[:event_id] == -1))
        if @default_group_id != @selected_group_id
          params[:selected_event_id] = nil
          params[:selected_attestation_requirement_fiscal_year_id] = nil
          params[:selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
          params[:selected_attestation_requirement_type_id] = nil
          session[:mass_maintenance_area_id] = nil
          params[:home_selected_attestation_requirement_fiscal_year_id] = nil
          params[:home_selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
          params[:home_selected_event_id] = nil
        end
        if @selected_group.group_type_id == 2
          @default_event = Event.events_by_group_and_group_type_id_and_fiscal_year(@selected_group, determine_fiscal_year_based_on_current_date(@selected_group))
          #@default_event = Event.event_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
          if @default_event.nil?
            @default_event = Event.event_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
          end
          if @default_event.nil?
            session[:event_id] = nil
          else
            session[:event_id] = @default_event.id
          end
        else
          session[:event_id] = -1
        end
        @default_event_id = session[:event_id]
      end
      @selected_attestation_requirement_fiscal_year_id = (params[:selected_attestation_requirement_fiscal_year_id] || @default_attestation_requirement_fiscal_year_id).to_i
      @group_type_fiscal_start = ""
      @group_type_fiscal_end = ""
      if !@selected_attestation_requirement_fiscal_year_id.nil? and @selected_attestation_requirement_fiscal_year_id.to_i > 0
        @selected_attestation_requirement_fiscal_year = AttestationRequirementFiscalYear.find(@selected_attestation_requirement_fiscal_year_id)
        @group_type_fiscal_start = @selected_attestation_requirement_fiscal_year.name
        @group_type_fiscal_end = @selected_attestation_requirement_fiscal_year.name
        if @selected_group.group_type_id == 2
          @group_type_fiscal_start = (@group_type_fiscal_start.to_i - 1).to_s
        end
        @group_type_fiscal_start += "-"+@selected_group.group_type.fiscal_start.to_s
        @group_type_fiscal_end += "-"+@selected_group.group_type.fiscal_end.to_s

        x_group_year = XGroupYear.find_or_create_by(group_id: @selected_group.id,
                                                    attestation_requirement_fiscal_year_id: @selected_attestation_requirement_fiscal_year_id)
        session[:scaling_factor_base] = x_group_year.scaling_factor_base.to_s
        session[:scaling_factor_bonus] = x_group_year.scaling_factor_bonus.to_s
      end
      session[:attestation_requirement_fiscal_year_id] = @selected_attestation_requirement_fiscal_year_id
      @selected_attestation_requirement_stage_id = (params[:selected_attestation_requirement_stage_id] || @default_attestation_requirement_stage_id).to_i
      session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
      @selected_attestation_requirement_type_id = (params[:selected_attestation_requirement_type_id] || 1).to_i
      session[:attestation_requirement_type_id] = @selected_attestation_requirement_type_id
      @selected_event_id = (params[:selected_event_id] || @default_event_id).to_i
      session[:event_id] = @selected_event_id

      @selected_events = Event.events_by_group_and_group_type_id_and_attestation_requirement_type_id(@selected_group) #events_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
      @selected_attestation_requirement_fiscal_years = Event.event_fiscal_years_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
      @selected_attestation_requirement_stages = Event.event_stages_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
      @selected_attestation_requirement_type = Event.event_types_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
      if @selected_group.group_type_id == 3 and @selected_attestation_requirement_stages.size == 1
        @selected_attestation_requirement_stage_id = @selected_attestation_requirement_stages.first[1].to_i
        session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
      end

      if @selected_group.group_type_id == 3 && ((@default_attestation_requirement_fiscal_year_id.to_i != @selected_attestation_requirement_fiscal_year_id || @default_attestation_requirement_stage_id.to_i != @selected_attestation_requirement_stage_id) || params[:selected_attestation_requirement_stage_id].nil? || (@selected_attestation_requirement_stage_id > -1 && controller_name == "report" && params[:selected_report_id] != '8'))# and controller_name != "report"
        physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).first
        if physician_event.nil? and (@selected_attestation_requirement_stages.size == 1 or (action_name != 'dashboard' and controller_name != 'home' and controller_name != 'aci' and controller_name != 'quality' and controller_name != 'batch_history' and (controller_name + action_name != 'cpiaaco_aggregation')) or @selected_attestation_requirement_stage_id > 0)  #or (@selected_attestation_requirement_stage_id.to_i == -1 and (controller_name == "requirement" or controller_name = "group_requirement")
          @first_selected_attestation_requirement_stage = Event.event_stage_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
          @selected_attestation_requirement_stage_id = @first_selected_attestation_requirement_stage.id.to_i
          session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
        end
        physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).first

        @selected_event_id = ((physician_event.nil?) ? -1 : physician_event.id).to_i
        session[:event_id] = @selected_event_id
      end

      if @user.user_type_id == 1 and [1, 2, 3, 6].include?(@user.security_level_id)
        if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
          @current_batch_jobs = JobHistory.where(job_status: ['Queued', 'Processing']).count
        else
          @current_batch_jobs = JobHistory.where(group_id: @selected_group.id, job_status: ['Queued', 'Processing']).count
        end
      end

      @url_host = request.env["HTTP_HOST"]
      if @selected_mum_program_view == 2
        @main_image = "/images/logos/MACRALoginLogo.png"
        # @main_image = "/images/logos/MIPSLoginLogo.png"
      else
        @main_image = "/images/logos/MUMLoginLogo.jpg"
      end
      if(@url_host == "icd10.meaningfulusemonitor.net")
        #@main_image = "/images/logos/ICD10PortalLogo.png"
        @main_image = "/images/logos/CustomerConciergeMonitorLogo.png"
      end
      #@logo_image = "/images/logos/"+((@selected_group.business_partner.nil?) ? "MUMLogoColorShort.gif" : @selected_group.business_partner.logo_image || "MUMLogoColorShort.gif")

      @logo_image = ((!@selected_group.business_partner.nil? and !@selected_group.business_partner.logo.nil?) ? @selected_group.business_partner.logo.public_filename : '')

      #rescue ActiveRecord::RecordNotFound
      #  flash[:notice] = "Logged in user not found"
      #  redirect_to :controller => "login", :action => "index"
      #end
    else
      flash[:notice] = "<span class='yes'>Please Log In</span>"
      session[:original_uri] = request.url
      redirect_to(login_url)
    end
  end

  def is_ambulatory
    redirect_to :controller => :home if @selected_group.group_type_id != 3
  end

  def authorize_http_basic
    @user = nil
    authenticate_with_http_basic do |id, password|
      @user = User.authenticate(id, password)
    end
    if (@user.nil?)
      render :nothing => true, :status => '401 Unauthorized'
    else
      @user_group = XUserGroup.find_by_user_id_and_status_and_active(@user.id, 1, 1)
      @group = @user_group.group
    end
    #@logo_image = ((!@selected_group.business_partner.nil? and !@selected_group.business_partner.logo_image.nil?) ? "/images/logos/"+@selected_group.business_partner.logo_image.to_s : '')
  end

  def authorize_admin
    prepare_session
    # unless can find a user and that user has true (1) for it's health_system.NotAHealthSystem value
    if User.find_by_id(session[:user_id]) && User.find_by_id(session[:user_id]).active? && User.find_by_id(session[:user_id]).status? && User.find_by_id(session[:user_id]).user_type_id.to_i == 1
      begin
        @user = User.find(session[:user_id].to_i)
        if session[:group_id].nil?
          @default_group = XUserGroup.find_by_user_id_and_status_and_active(@user.id, 1, 1)
          session[:group_id] = @default_group.group_id
        end
        if session[:attestation_clinic_id_portal].nil? || session[:group_id] != params[:selected_group_id].to_i
          session[:attestation_clinic_id_portal] = -1
        end
        @default_group_id = session[:group_id]
        @selected_group_id = (params[:selected_group_id] || @default_group_id).to_i
        session[:group_id] = @selected_group_id
        @selected_event_id = (params[:selected_event_id] || -1).to_i
        @selected_user_group = XUserGroup.find_by_user_id(@user.id)
        @selected_groups = Group.GetFilteredGroupsBySecurity_Level(@user, @selected_user_group, @selected_user_group.group.health_system_id)
        @selected_group = Group.find(@selected_group_id)

        # if @selected_group.x_group_mum_programs.empty?
        #   default_group_mum_program = XGroupMumProgram.new
        #   default_group_mum_program.group_id = @selected_group.id
        #   default_group_mum_program.mum_program_id = 1
        #   default_group_mum_program.active = true
        #   group_mips_mum_program = XGroupMumProgram.new
        #   group_mips_mum_program.group_id = @selected_group.id
        #   group_mips_mum_program.mum_program_id = 2
        #   default_group_mum_program.save
        #   group_mips_mum_program.save
        # end
        if session[:mum_program_view].nil?
          # session[:mum_program_view] = @selected_group.preferred_mum_program_id
          session[:mum_program_view] = 2
        end
        if @default_group_id != @selected_group_id
          redirect_to root_path
        end
        if @default_group_id != @selected_group_id
          params[:selected_attestation_clinic_id_portal] = -1
        end
        @default_mum_program_view = session[:mum_program_view]
        @selected_mum_program_view = (params[:selected_mum_program_view] || @default_mum_program_view).to_i
        session[:mum_program_view] = @selected_mum_program_view

        @default_attestation_clinic_id_portal = session[:attestation_clinic_id_portal]
        @selected_attestation_clinic_id_portal = (params[:selected_attestation_clinic_id_portal] || @default_attestation_clinic_id_portal).to_i
        session[:attestation_clinic_id_portal] = @selected_attestation_clinic_id_portal

        @accepted_security_levels = [4]
        @accepted_user_types = [1, 2]
        if @accepted_security_levels.include? @user.security_level_id and @accepted_user_types.include? @user.user_type_id
          @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentOwnerID_And_DepartmentCount_for_select_in_form(@selected_group.id, @user.id)
        else
          @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentCount_for_select_in_form(@selected_group.id)
        end
        if @selected_attestation_clinics_portal.size == 1
          @selected_attestation_clinic_id_portal = @selected_attestation_clinics_portal.first[1]
        end

        @default_event_id = session[:event_id]
        @default_attestation_requirement_fiscal_year_id = session[:attestation_requirement_fiscal_year_id]
        @default_attestation_requirement_stage_id = session[:attestation_requirement_stage_id] || @selected_group.default_attestation_requirement_stage_id || -1
        @default_attestation_requirement_type_id = session[:attestation_requirement_type_id]
        @default_attestation_requirement_fiscal_year = {}
        if(@selected_group.group_type_id != 1 and @selected_group.group_type_id != 4)
          @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
          if @default_attestation_requirement_fiscal_year_id.nil? or @default_attestation_requirement_fiscal_year_id <= 0
            if @default_attestation_requirement_fiscal_year.nil?
              @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
            end
            @default_attestation_requirement_fiscal_year_id = @default_attestation_requirement_fiscal_year.id.to_i
          end
        end
        if(@default_group_id != @selected_group_id) or ((params[:selected_event_id].nil? or params[:selected_event_id] == -1) and (session[:event_id].nil? or session[:event_id] == -1))
          if @default_group_id != @selected_group_id
            params[:selected_event_id] = nil
            params[:selected_attestation_requirement_fiscal_year_id] = nil
            params[:selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
            params[:selected_attestation_requirement_type_id] = nil
            params[:home_selected_attestation_requirement_fiscal_year_id] = nil
            params[:home_selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
            params[:home_selected_event_id] = nil
          end
          if @selected_group.group_type_id == 2
            @default_event = Event.events_by_group_and_group_type_id_and_fiscal_year(@selected_group, determine_fiscal_year_based_on_current_date(@selected_group))
            # @default_event = Event.event_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
            if @default_event.nil?
              @default_event = Event.event_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
            end
            if @default_event.nil?
              session[:event_id] = nil
            else
              session[:event_id] = @default_event.id
            end
          else
            session[:event_id] = -1
          end
          @default_event_id = session[:event_id]
        end
        @selected_attestation_requirement_fiscal_year_id = (params[:selected_attestation_requirement_fiscal_year_id] || @default_attestation_requirement_fiscal_year_id).to_i
        @group_type_fiscal_start = ""
        @group_type_fiscal_end = ""
        if !@selected_attestation_requirement_fiscal_year_id.nil? and @selected_attestation_requirement_fiscal_year_id.to_i > 0
          @selected_attestation_requirement_fiscal_year = AttestationRequirementFiscalYear.find(@selected_attestation_requirement_fiscal_year_id)
          @group_type_fiscal_start = @selected_attestation_requirement_fiscal_year.name
          @group_type_fiscal_end = @selected_attestation_requirement_fiscal_year.name
          if @selected_group.group_type_id == 2
            @group_type_fiscal_start = (@group_type_fiscal_start.to_i - 1).to_s
          end
          @group_type_fiscal_start += "-"+@selected_group.group_type.fiscal_start.to_s
          @group_type_fiscal_end += "-"+@selected_group.group_type.fiscal_end.to_s

          x_group_year = XGroupYear.find_or_create_by_group_id_and_attestation_requirement_fiscal_year_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id)
          session[:scaling_factor_base] = x_group_year.scaling_factor_base.to_s
          session[:scaling_factor_bonus] = x_group_year.scaling_factor_bonus.to_s
        end

        session[:attestation_requirement_fiscal_year_id] = @selected_attestation_requirement_fiscal_year_id
        @selected_attestation_requirement_stage_id = (params[:selected_attestation_requirement_stage_id] || @default_attestation_requirement_stage_id).to_i
        session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
        @selected_attestation_requirement_type_id = (params[:selected_attestation_requirement_type_id] || 1).to_i
        session[:attestation_requirement_type_id] = @selected_attestation_requirement_type_id
        @selected_event_id = (params[:selected_event_id] || @default_event_id).to_i
        session[:event_id] = @selected_event_id

        @selected_events = Event.events_by_group_and_group_type_id_and_attestation_requirement_type_id(@selected_group) #events_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
        @selected_attestation_requirement_fiscal_years = Event.event_fiscal_years_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
        @selected_attestation_requirement_stages = Event.event_stages_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
        @selected_attestation_requirement_type = Event.event_types_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
        if @selected_group.group_type_id == 3 and @selected_attestation_requirement_stages.size == 1
          @selected_attestation_requirement_stage_id = @selected_attestation_requirement_stages.first[1].to_i
          session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
        end

        if @selected_group.group_type_id == 3
          physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).first
          if physician_event.nil? and (action_name != 'dashboard' or @selected_attestation_requirement_stage_id > 0) #or (@selected_attestation_requirement_stage_id.to_i == -1 and (controller_name == "requirement" or controller_name = "group_requirement")
            @first_selected_attestation_requirement_stage = Event.event_stage_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
            @selected_attestation_requirement_stage_id = @first_selected_attestation_requirement_stage.id.to_i
            session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
          end
          physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).firstt

          @selected_event_id = ((physician_event.nil?) ? -1 : physician_event.id).to_i
          session[:event_id] = @selected_event_id
        end

        if @user.user_type_id == 1 and [1, 2, 3, 6].include?(@user.security_level_id)
          if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
            @current_batch_jobs = JobHistory.find_all_by_job_status(['Queued', 'Processing']).size
          else
            @current_batch_jobs = JobHistory.find_all_by_group_id_and_job_status(@selected_group.id, ['Queued', 'Processing']).size
          end
        end

        @url_host = request.env["HTTP_HOST"]
        if @selected_mum_program_view == 2
          @main_image = "/images/logos/MACRALoginLogo.png"
          # @main_image = "/images/logos/MIPSLoginLogo.png"
        else
          @main_image = "/images/logos/MUMLoginLogo.jpg"
        end
        if(@url_host == "icd10.meaningfulusemonitor.net")
          #@main_image = "/images/logos/ICD10PortalLogo.png"
          @main_image = "/images/logos/CustomerConciergeMonitorLogo.png"
        end
        #@logo_image = "/images/logos/"+((@selected_group.business_partner.nil?) ? "MUMLogoColorShort.gif" : @selected_group.business_partner.logo_image || "MUMLogoColorShort.gif")
        @logo_image = ((!@selected_group.business_partner.nil? and !@selected_group.business_partner.logo.nil?) ? @selected_group.business_partner.logo.public_filename : '')

        if @user.security_level_id == 2
          accepted_controllers = ["group", "attestation_clinic", "clinic", "pecos_clinic", "user", "department", "group_user_defined_value", "mass_maintenance", "group_actual_payment", "group_attestation_requirement_template"]
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :group, :action => :index
          end
        end
        if @user.security_level_id == 3
          accepted_controllers = ["group", "attestation_clinic", "clinic", "pecos_clinic", "user", "department", "group_user_defined_value", "mass_maintenance", "group_actual_payment", "group_attestation_requirement_template"]
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :group, :action => :index
          end
        end
        if @user.security_level_id == 4
          accepted_controllers = []
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :home, :action => :index
          end
        end
        if @user.security_level_id == 5
          accepted_controllers = []
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :event, :action => :index
          end
        end
        if @user.security_level_id == 6
          accepted_controllers = ["health_system", "group", "attestation_clinic", "clinic", "pecos_clinic", "user", "department", "group_user_defined_value", "mass_maintenance", "group_actual_payment", "group_attestation_requirement_template"]
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :group, :action => :index
          end
        end

      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Logged in user not found"
        redirect_to(login_url)
      end
    else
      flash[:notice] = "<span class='yes'>Please Log In</span>"
      session[:original_uri] = request.url
      redirect_to(login_url)
    end
  end


  def prepare_session
    @max_session_time = MAX_SESSION_TIME.seconds
    current_time = Time.zone.now #user_time_zone_now
    if !session[:expiry_time].nil? and session[:expiry_time] < current_time #Time.zone.now
      # Session has expired. Clear the current session.
      reset_session
    end

    # Assign a new expiry time, whether the session has expired or not.
    session[:expiry_time] =  MAX_SESSION_TIME.seconds.from_now #current_time + MAX_SESSION_TIME.seconds #.from.@current_time
    session[:expiry_time_server] = MAX_SESSION_TIME.seconds.from_now
    return true
  end

  def qpp_submission_api_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    attestation_clinic = AttestationClinic.find attestation_clinic_id
    if !attestation_clinic.group.qpp_api_token.blank?
      qpp_direct_submit_api_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    else
      suncoast_submit_api_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    end
  end

  def qpp_direct_submit_api_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    body_set = qpp_submission_object_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    if body_set.size > 0
      fiscal_year = AttestationRequirementFiscalYear.find_by_name(body_set[:performanceYear])
      attestation_clinic = AttestationClinic.find(attestation_clinic_id)
      if attestation_clinic.group_id == @selected_group_id and fiscal_year
        # Response.destroy_all(:attestation_clinic_id => attestation_clinic_id,
        #                      :attestation_requirement_fiscal_year_id => fiscal_year.id)
        response = Response.find_or_create_by(:attestation_clinic_id => attestation_clinic_id,
                                              :tin => body_set[:taxpayerIdentificationNumber],
                                              :npi => body_set[:nationalProviderIdentifier],
                                              :attestation_requirement_fiscal_year_id => fiscal_year.id)
        response.response_errors.delete_all
        response.update_attribute(:content, nil)

        token = attestation_clinic.group.qpp_api_token
        submission_fields = {:entityType => body_set[:entityType],
                             :taxpayerIdentificationNumber => body_set[:taxpayerIdentificationNumber],
                             :nationalProviderIdentifier => body_set[:nationalProviderIdentifier],
                             :performanceYear => body_set[:performanceYear]}
        body_set[:measurementSets].each do |measurement_set|
          category = measurement_set[:category]
          base_api = ApplicationConfiguration.get_qpp_submission_api_endpoint + 'measurement-sets'

          measurement_set_id_for_category = nil
          case category
            when 'pi'
              measurement_set_id_for_category = response.aci_measurement_set_id
            when 'quality'
              measurement_set_id_for_category = response.quality_measurement_set_id
            when 'ia'
              measurement_set_id_for_category = response.cpia_measurement_set_id
          end

          if measurement_set_id_for_category.nil?
            uri = URI.parse(base_api)
            request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
            measurement_set[:submission] = submission_fields
          else # measurement_set_id for category exists, do PUT and append measurement_set_id to base_api
            base_api += "/#{measurement_set_id_for_category}"
            uri = URI.parse(base_api)
            request = Net::HTTP::Put.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
          end

          request.body = JSON.generate(measurement_set)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http_response = http.request(request)
          begin
            http_response_body = JSON.parse(http_response.body)
          rescue JSON::ParserError
            http_response_body = {'error' => {'type' => 'Response is not JSON', 'message' => http_response.body.to_s}}
          end

          if http_response.code == '200'
            # api submission was good!
          elsif http_response.code == '201'
            # api submission good and created measurement set!
            # TODO store this in database
            submission_id = http_response_body['data']['measurementSet']['submissionId']
            response.update_attribute(:submission_id, submission_id) if response.submission_id.nil?

            measurement_set_id = http_response_body['data']['measurementSet']['id']
            case category
              when 'pi'
                response.update_attribute(:aci_measurement_set_id, measurement_set_id) if response.aci_measurement_set_id.nil?
              when 'quality'
                response.update_attribute(:quality_measurement_set_id, measurement_set_id) if response.quality_measurement_set_id.nil?
              when 'ia'
                response.update_attribute(:cpia_measurement_set_id, measurement_set_id) if response.cpia_measurement_set_id.nil?
            end
          elsif http_response_body['error'] and http_response_body['error']['type'] == 'DuplicateEntryError'
            # TODO entry exists so store submission id, get submission, save measurement_set_id for categories
            submission_id = http_response_body['error']['details'][0]['submissionId']

          elsif http_response_body['error']
            error_type = http_response_body['error']['type']
            response.response_errors.create(:error_type => "#{category}: #{error_type}",
                                            :message => http_response_body['error']['message'])
            if http_response_body['error']['details']
              http_response_body['error']['details'].each do |error_detail|
                if error_detail['message']
                  response.response_errors.create(:error_type => "#{category}: #{error_type}", :message => error_detail['message'])
                end
              end
            end

            if error_type == 'DuplicateEntryError'
              submission_id = http_response_body['error']['details'][0]['submissionId']
              if response.submission_id.nil?
                response.update_attribute(:submission_id, submission_id)
              end
              if response.submission_id == submission_id
                measurement_set_ids = qpp_direct_get_measurement_set_ids_api_by_group_and_submission_id(attestation_clinic.group, response.submission_id)
                measurement_set_ids.each do |key, measurement_set_id|
                  case key
                    when :aci_measurement_set_id
                      response.update_attribute(:aci_measurement_set_id, measurement_set_id) if response.aci_measurement_set_id.nil?
                    when :quality_measurement_set_id
                      response.update_attribute(:quality_measurement_set_id, measurement_set_id) if response.quality_measurement_set_id.nil?
                    when :cpia_measurement_set_id
                      response.update_attribute(:cpia_measurement_set_id, measurement_set_id) if response.cpia_measurement_set_id.nil?
                    when :other
                      response.response_errors.create(:error_type => "#{category}: submission_id (#{response.submission_id})" \
                                                               " has measurement sets with unknown categories (#{measurement_set_id})",
                                                      :message => http_response_body['message'])
                  end
                end
              else
                response.response_errors.create(:error_type => "#{category}: C3 MACRA submission_id (#{response.submission_id})" \
                                                               " doesn't match submission_id in QPP API (#{submission_id})",
                                                :message => http_response_body['message'])
              end
            end
          elsif http_response_body['error'] and http_response_body['message']
            response.response_errors.create(:error_type => "#{category}: #{http_response_body['error']}",
                                            :message => http_response_body['message'])
          else
            # not sure what the response is
            response.response_errors.create(:error_type => "#{category}: Unknown response",
                                            :message => http_response_body)
          end


          if http_response.code == '200' || http_response.code == '201'
            submission_content = qpp_direct_get_submission_api_by_group_and_submission_id(attestation_clinic.group, response.submission_id)
            if submission_content['error']
              response.response_errors.create(:error_type => "QPP Get Submission Content: #{submission_content['error']['type']}",
                                              :message => submission_content['error']['message'])
            end
            score_content = qpp_direct_get_submission_score_api_by_group_and_submission_id(attestation_clinic.group, response.submission_id)
            if score_content['error']
              response.response_errors.create(:error_type => "QPP Get Score Preview: #{score_content['error']['type']}",
                                              :message => score_content['error']['message'])
            end
            response.update_attribute(:content, submission_content.to_json)
            response.update_attribute(:cms_score_content, score_content.to_json)
            response.process_cms_score_content
          end
        end
      end
    else
      # Empty object
    end
  end

  def qpp_direct_get_submission_score_api_by_group_and_submission_id(group, submission_id)
    base_api = ApplicationConfiguration.get_qpp_submission_api_endpoint
    uri = URI.parse(base_api + "submissions/#{submission_id}/score")
    token = group.qpp_api_token
    request = Net::HTTP::Get.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http_response = http.request(request)

    begin
      http_response_body = JSON.parse(http_response.body)
      # For now formatting it like how Suncoast gives it to us to make parsing the same.
      suncoast_formatted_score = {'submissionId' => submission_id, 'score' => http_response_body}
    rescue JSON::ParserError
      suncoast_formatted_score = {'error' => {'type' => 'Response is not JSON', 'message' => http_response.body.to_s}}
    end

    suncoast_formatted_score
  end

  def qpp_direct_get_submission_api_by_group_and_submission_id(group, submission_id)
    base_api = ApplicationConfiguration.get_qpp_submission_api_endpoint
    uri = URI.parse(base_api + "submissions/#{submission_id}")
    token = group.qpp_api_token
    request = Net::HTTP::Get.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http_response = http.request(request)

    begin
      http_response_body = JSON.parse(http_response.body)
    rescue JSON::ParserError
      http_response_body = {'error' => {'type' => 'Response is not JSON', 'message' => http_response.body.to_s}}
    end

    http_response_body
  end

  def qpp_direct_get_measurement_set_ids_api_by_group_and_submission_id(group, submission_id)
    measurement_set_ids = {}

    http_response_body = qpp_direct_get_submission_api_by_group_and_submission_id(group, submission_id)

    if http_response_body['data'] and http_response_body['data']['submission'] and http_response_body['data']['submission']['measurementSets']
      http_response_body['data']['submission']['measurementSets'].each do |measurement_set|
        case measurement_set['category']
          when 'pi'
            measurement_set_ids[:aci_measurement_set_id] = measurement_set['id']
          when 'quality'
            measurement_set_ids[:quality_measurement_set_id] = measurement_set['id']
          when 'ia'
            measurement_set_ids[:cpia_measurement_set_id] = measurement_set['id']
          else
            measurement_set_ids[:other] ||= []
            measurement_set_ids[:other] << measurement_set['category']
        end
      end
    end

    measurement_set_ids
  end

  def suncoast_submit_api_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    body_set = qpp_submission_object_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id)
    if body_set.size > 0
      fiscal_year = AttestationRequirementFiscalYear.find_by_name(body_set[:performanceYear])
      attestation_clinic = AttestationClinic.find(attestation_clinic_id)
      if attestation_clinic.group_id == @selected_group_id and fiscal_year
        Response.destroy_all(:attestation_clinic_id => attestation_clinic_id,
                             :attestation_requirement_fiscal_year_id => fiscal_year.id)
        response = Response.create(:attestation_clinic_id => attestation_clinic_id,
                                   :tin => body_set[:taxpayerIdentificationNumber],
                                   :npi => body_set[:nationalProviderIdentifier],
                                   :attestation_requirement_fiscal_year_id => fiscal_year.id)

        base_api = 'https://suncoastapi.herokuapp.com/apisc/processqpp'
        uri = URI.parse(base_api)
        token = ApplicationConfiguration.get_token
        request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
        request.body = JSON.generate(body_set)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http_response = http.request(request)
        begin
          http_response_body = JSON.parse(http_response.body)
        rescue JSON::ParserError
          http_response_body = {'error' => 'Response is not JSON', 'message' => http_response.body.to_s}
        end

        if http_response_body['response'] and http_response_body['response'] == 'OK'
          # api submission was good!
        elsif http_response_body['errors'] and http_response_body['errors'].size > 0
          http_response_body['errors'].each do |error|
            error_type = error['detail']['error']['type']

            if error['detail']['error']['details'] and error['detail']['error']['details'].size > 0
              error['detail']['error']['details'].each do |error_detail|
                response.response_errors.create(:error_type => error_type, :message => error_detail['message'])
              end
            else
              response.response_errors.create(:error_type => error_type, :message => error['detail']['error']['message'])
            end
          end
        elsif http_response_body['error'] and http_response_body['message']
          response.response_errors.create(:error_type => http_response_body['error'],
                                          :message => http_response_body['message'])
        else
          # not sure what the response is
        end
      end
    else
      # Empty object
    end
  end

  def qpp_submission_object_attestation_clinic(attestation_clinic_id, event_id, attestation_method_id, forced_submission_method = nil)
    body_set = {}
    file_name = 'default_name'
    # x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    # if x_attestation_clinic_event and x_attestation_clinic_event.default_attestation_method and x_attestation_clinic_event.default_attestation_method.has_clinic_rollup?
    xceam = XClinicEventAttestMethod.find_by_attestation_clinic_id_and_event_id_and_attestation_method_id(attestation_clinic_id, event_id, attestation_method_id)
    if xceam and (xceam.submission_method or (!xceam.quality_submit_flag and xceam.override_submission_method))
      entity_type = 'group'
      if forced_submission_method.nil?
        if xceam.quality_submit_flag
          submission_method = xceam.submission_method.json_name_key
        else
          submission_method = (xceam.override_submission_method or xceam.submission_method).json_name_key
        end
      else
        submission_method = forced_submission_method
      end

      body_set = {:entityType => entity_type,
                  :taxpayerIdentificationNumber => xceam.attestation_clinic.TIN,
                  :nationalProviderIdentifier => '',
                  :performanceYear => xceam.event.attestation_requirement_fiscal_year.name.to_i}

      measurement_sets = []

      # ACI Measurement Set Section
      aci_min_date = nil
      aci_max_date = nil
      if xceam.aci_submit_flag
        aci_manual = (xceam.aci_use_manual_fields_flag ? 'manual_' : '')
        aci_measurements = []
        dep_reqs = XClinicEventAttestGroupRequirement.group_requirements_for_aci_submission_json_by_clinic_id_and_attestation_method_id_and_event_id(attestation_clinic_id, attestation_method_id, event_id, xceam.aci_use_manual_fields_flag)
        dep_reqs.each do |req|
          req_json = requirement_to_json(req)
          unless req_json.nil?
            aci_measurements << req_json
            if (aci_min_date.nil? or aci_max_date.nil?) and (req.send("#{aci_manual}current_measure_start_date") and req.send("#{aci_manual}current_measure_end_date"))
              aci_min_date = req.send("#{aci_manual}current_measure_start_date")
              aci_max_date = req.send("#{aci_manual}current_measure_end_date")
            end
          end
        end

        xace = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
        cehrt = (xace.nil? ? '' : xace.cehrt)
        measurement_sets << {:category => 'pi',
                             :submissionMethod => submission_method,
                             :programName => 'mips', # mips, cpcPlus     mips is default if left blank
                             # :practiceId => '', # REQUIRED IF :programName => 'cpcPlus'
                             :performanceStart => aci_min_date.to_s,
                             :performanceEnd => aci_max_date.to_s,
                             # :measureSet => '', # optional, has lots of possible values
                             :cehrtId => cehrt,
                             :measurements => aci_measurements}
      end

      # Quality Measurement Set Section
      if xceam.quality_submit_flag
        quality_manual = (xceam.quality_use_manual_fields_flag ? 'manual_' : '')
        quality_measurements = []
        dep_reqs = XClinicEventAttestGroupRequirement.group_requirements_for_cqm_submission_json_by_clinic_id_and_attestation_method_id_and_event_id(attestation_clinic_id, attestation_method_id, event_id, xceam.quality_use_manual_fields_flag)
        dep_reqs.each do |req|
          req_json = requirement_to_json(req)
          unless req_json.nil?
            quality_measurements << req_json
          end
        end

        measurement_sets << {:category => 'quality',
                             :submissionMethod => submission_method,
                             :programName => 'mips', # mips, cpcPlus     mips is default if left blank
                             # :practiceId => '', # REQUIRED IF :programName => 'cpcPlus'
                             :performanceStart => xceam.send("#{quality_manual}quality_submission_start_date").to_s,
                             :performanceEnd => xceam.send("#{quality_manual}quality_submission_end_date").to_s,
                             # :measureSet => '', # optional, has lots of possible values
                             :measurements => quality_measurements}
      end

      # CPIA Measurement Set Section
      if xceam.cpia_submit_flag
        cpia_measurements = []
        cpia_min_date = Date.new(xceam.event.attestation_requirement_fiscal_year.name.to_i)
        cpia_max_date = cpia_min_date.end_of_year
        xdcs_id = XDepartmentCriterionRequirement.xdcs_id_with_most_points_by_clinic_id_and_attestation_method_id_and_event_id(attestation_clinic_id, attestation_method_id, event_id)
        if xdcs_id
          xdcs = XDepartmentCriterionStatus.find(xdcs_id)
          dep_reqs = XDepartmentCriterionRequirement.group_requirements_for_cpia_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(xdcs.department_id, event_id, attestation_clinic_id)
        else
          dep_reqs = []
        end
        dep_reqs.each do |req|
          req_json = requirement_to_json(req)
          unless req_json.nil?
            cpia_measurements << req_json
            if (cpia_min_date.nil? or cpia_max_date.nil?) and req.current_measure_start_date and req.current_measure_end_date
              cpia_min_date = req.current_measure_start_date
              cpia_max_date = req.current_measure_end_date
            end
          end
        end

        measurement_sets << {:category => 'ia',
                             :submissionMethod => submission_method,
                             :programName => 'mips', # mips, cpcPlus     mips is default if left blank
                             # :practiceId => '', # REQUIRED IF :programName => 'cpcPlus'
                             :performanceStart => cpia_min_date.to_s,
                             :performanceEnd => cpia_max_date.to_s,
                             # :measureSet => '', # optional, has lots of possible values
                             :measurements => cpia_measurements}
      end

      body_set[:measurementSets] = measurement_sets

      # file_name = "#{x_attestation_clinic_event.attestation_clinic.name}_qpp_submission_group"
    end
    # end
    # stream_json("#{file_name}.json", body_set)
    return body_set
  end

  def download_zip_qpp_submission_departments(attestation_clinic_id, event_id, attestation_method_id)
    # x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    attestation_clinic = AttestationClinic.find(attestation_clinic_id)
    event = Event.find(event_id)
    x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(event.attestation_requirement_fiscal_year_id, attestation_method_id)
    selected_low_volume = -1
    file_contents = []
    departments = Department.Group_Departments_By_GroupID_ClinicID_EventID_XYearAttestationMethodID_UserDefinedFields_DepartmentOwnerID(attestation_clinic.group_id, attestation_clinic_id, event_id, x_year_attestation_method.id, ['-1'], -1, -1, selected_low_volume)

    file_names = []
    file_path_prefix = "qpp_submission_files/#{attestation_clinic.group_id}/#{attestation_clinic_id}/#{event_id}"
    zip_name = "#{attestation_clinic.name}_qpp_submission_individual.zip"
    zip_path_and_name = "#{file_path_prefix}/#{zip_name}"
    FileUtils::mkdir_p(file_path_prefix)
    File.delete(zip_path_and_name) if File.exist?(zip_path_and_name)
    Zip::ZipFile.open(zip_path_and_name, Zip::ZipFile::CREATE) do |zip_file|
      departments.each do |department|
        departments_section = qpp_submission_object_department(department, attestation_clinic_id, event_id, SubmissionMethod.find(SubmissionMethod.ehr_id).json_name_key)
        unless departments_section.nil?
          # file_contents << departments_section
          # file_name = "#{x_attestation_clinic_event.attestation_clinic.name}_qpp_submission_individual"

          file_name = "#{department.name}_#{department.npi}.json"
          file_path_and_name = "#{file_path_prefix}/#{department.name}_#{department.npi}.json"
          temp_file = File.new(file_path_and_name, "w")
          temp_file.puts(JSON.pretty_generate(departments_section))
          # begin
          #   temp_file.puts(JSON.generate(departments_section))
          # rescue ArgumentError => e
          #   temp_file.puts(departments_section.inspect)
          # end
          temp_file.close

          zip_file.add(file_name, temp_file.path)

          file_names << file_path_and_name
        end
      end
    end
    file_names.each do |f_name|
      File.delete(f_name)
    end

    # stream_json("#{file_name}.json", file_contents)
    send_file zip_path_and_name, :type => 'application/zip', :disposition => 'attachment', :filename => zip_name
  end

  def qpp_submission_object_department(department, attestation_clinic_id, event_id, forced_submission_method = nil)
    body_set = nil
    arsd = AttestationRequirementSetDetail.AttestationRequirementSetDetails_By_Department_EventID_AttestationClinicID(department, event_id, attestation_clinic_id)
    x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    if arsd and arsd.x_year_attestation_method and arsd.submission_method and arsd.x_year_attestation_method and x_attestation_clinic_event
      entity_type = 'individual'
      # TODO 03/14 For now just hard code EHR as the submission method
      # submission_method = arsd.submission_method.json_name_key
      ############## The below will be removed #######################
      if forced_submission_method.nil?
        submission_method = arsd.submission_method.json_name_key
      else
        submission_method = forced_submission_method
      end
      ############## TODO 03/14

      # if x_attestation_clinic_event.quality_submit_flag
      #   submission_method = arsd.submission_method.json_name_key
      # else
      #   submission_method = (arsd.override_submission_method or arsd.submission_method).json_name_key
      # end

      attestation_clinic = AttestationClinic.find(attestation_clinic_id)

      body_set = {:entityType => entity_type,
                  :taxpayerIdentificationNumber => attestation_clinic.TIN,
                  :nationalProviderIdentifier => department.npi,
                  :performanceYear => arsd.event.attestation_requirement_fiscal_year.name.to_i}

      measurement_sets = []

      # ACI Measurement Set Section
      aci_min_date = nil
      aci_max_date = nil
      if x_attestation_clinic_event.aci_submit_flag
        aci_measurements = []
        dep_reqs = XDepartmentCriterionRequirement.group_requirements_for_aci_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(department.id, arsd.event_id, attestation_clinic_id)
        dep_reqs.each do |req|
          req_json = requirement_to_json(req)
          unless req_json.nil?
            aci_measurements << req_json
            if (aci_min_date.nil? or aci_max_date.nil?) and (req.current_measure_start_date and req.current_measure_end_date)
              aci_min_date = req.current_measure_start_date
              aci_max_date = req.current_measure_end_date
            end
          end
        end

        measurement_sets << {:category => 'pi',
                             :submissionMethod => submission_method,
                             :programName => 'mips', # mips, cpcPlus     mips is default if left blank
                             # :practiceId => '', # REQUIRED IF :programName => 'cpcPlus'
                             :performanceStart => aci_min_date.to_s,
                             :performanceEnd => aci_max_date.to_s,
                             # :measureSet => '', # optional, has lots of possible values
                             :cehrtId => x_attestation_clinic_event.cehrt,
                             :measurements => aci_measurements}
      end

      # Quality Measurement Set Section
      if x_attestation_clinic_event.quality_submit_flag
        quality_measurements = []
        dep_reqs = XDepartmentCriterionRequirement.group_requirements_for_cqm_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(department.id, arsd.event_id, attestation_clinic_id)
        dep_reqs.each do |req|
          req_json = requirement_to_json(req)
          unless req_json.nil?
            quality_measurements << req_json
          end
        end

        measurement_sets << {:category => 'quality',
                             :submissionMethod => submission_method,
                             :programName => 'mips', # mips, cpcPlus     mips is default if left blank
                             # :practiceId => '', # REQUIRED IF :programName => 'cpcPlus'
                             :performanceStart => arsd.quality_submission_start_date.to_s,
                             :performanceEnd => arsd.quality_submission_end_date.to_s,
                             # :measureSet => '', # optional, has lots of possible values
                             :measurements => quality_measurements}
      end

      # CPIA Measurement Set Section
      if x_attestation_clinic_event.cpia_submit_flag
        cpia_measurements = []
        cpia_min_date = Date.new(arsd.event.attestation_requirement_fiscal_year.name.to_i)
        cpia_max_date = cpia_min_date.end_of_year
        dep_reqs = XDepartmentCriterionRequirement.group_requirements_for_cpia_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(department.id, arsd.event_id, attestation_clinic_id)
        dep_reqs.each do |req|
          req_json = requirement_to_json(req)
          unless req_json.nil?
            cpia_measurements << req_json
            if (cpia_min_date.nil? or cpia_max_date.nil?) and (req.current_measure_start_date and req.current_measure_end_date)
              cpia_min_date = req.current_measure_start_date
              cpia_max_date = req.current_measure_end_date
            end
          end
        end

        measurement_sets << {:category => 'ia',
                             :submissionMethod => submission_method,
                             :programName => 'mips', # mips, cpcPlus     mips is default if left blank
                             # :practiceId => '', # REQUIRED IF :programName => 'cpcPlus'
                             :performanceStart => cpia_min_date.to_s,
                             :performanceEnd => cpia_max_date.to_s,
                             # :measureSet => '', # optional, has lots of possible values
                             :measurements => cpia_measurements}
      end

      body_set[:measurementSets] = measurement_sets

      # file_name = "#{department.name}_qpp_submission"
      # stream_json("#{file_name}.json", body_set)
    end

    return body_set
  end

  def qpp_submission_api_departments(attestation_clinic_id, event_id, attestation_method_id)
    attestation_clinic = AttestationClinic.find(attestation_clinic_id)
    event = Event.find(event_id)
    attestation_method = AttestationMethod.find(attestation_method_id)
    x_attestation_clinic_event = XAttestationClinicEvent.find_by_attestation_clinic_id_and_event_id(attestation_clinic_id, event_id)
    x_year_attestation_method = XYearAttestationMethod.find_by_attestation_requirement_fiscal_year_id_and_attestation_method_id(event.attestation_requirement_fiscal_year_id, attestation_method_id)
    selected_low_volume = -1
    departments = Department.Group_Departments_By_GroupID_ClinicID_EventID_XYearAttestationMethodID_UserDefinedFields_DepartmentOwnerID(attestation_clinic.group_id, attestation_clinic_id, event_id, x_year_attestation_method.id, ['-1'], -1, -1, selected_low_volume)

    departments.each do |department|
      arsd = AttestationRequirementSetDetail.AttestationRequirementSetDetails_By_Department_EventID_AttestationClinicID(department, event_id, attestation_clinic_id)
      if arsd and arsd.submission_method_id == SubmissionMethod.registry_id
        qpp_submission_api_department(department, attestation_clinic_id, event_id)
      end
    end
  end

  def qpp_submission_api_department(department, attestation_clinic_id, event_id)
    if !department.group.qpp_api_token.blank?
      qpp_direct_submit_api_department(department, attestation_clinic_id, event_id)
    else
      suncoast_submit_api_department(department, attestation_clinic_id, event_id)
    end
  end

  def qpp_direct_submit_api_department(department, attestation_clinic_id, event_id)
    body_set = qpp_submission_object_department(department, attestation_clinic_id, event_id)
    if body_set.size > 0
      fiscal_year = AttestationRequirementFiscalYear.find_by_name(body_set[:performanceYear])
      if department.group_id == @selected_group_id and fiscal_year and body_set[:nationalProviderIdentifier]
        # Response.destroy_all(:attestation_clinic_id => attestation_clinic_id,
        #                      :npi => body_set[:nationalProviderIdentifier],
        #                      :attestation_requirement_fiscal_year_id => fiscal_year.id)
        response = Response.find_or_create_by(:attestation_clinic_id => attestation_clinic_id,
                                              :tin => body_set[:taxpayerIdentificationNumber],
                                              :npi => body_set[:nationalProviderIdentifier],
                                              :attestation_requirement_fiscal_year_id => fiscal_year.id)
        response.response_errors.delete_all

        submission_fields = {:entityType => body_set[:entityType],
                             :taxpayerIdentificationNumber => body_set[:taxpayerIdentificationNumber],
                             :nationalProviderIdentifier => body_set[:nationalProviderIdentifier],
                             :performanceYear => body_set[:performanceYear]}
        body_set[:measurementSets].each do |measurement_set|
          category = measurement_set[:category]

          base_api = ApplicationConfiguration.get_qpp_submission_api_endpoint + 'measurement-sets'
          # TODO
          # if no measurement_set_id for category, add submission fields and do POST
          measurement_set[:submission] = submission_fields
          # else measurement_set_id for category exists, do PUT and append measurement_set_id to base_api
          #   base_api += "/#{measurement_set_id_for_category}"
          # end

          uri = URI.parse(base_api)
          token = department.group.qpp_api_token
          request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
          request.body = JSON.generate(body_set)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http_response = http.request(request)
          begin
            http_response_body = JSON.parse(http_response.body)
          rescue JSON::ParserError
            http_response_body = {'error' => {'type' => 'Response is not JSON', 'message' => http_response.body.to_s}}
          end

          if http_response.code == '200'
            # api submission was good!
          elsif http_response.code == '201'
            # api submission good and created measurement set!
            # TODO store this in database
            submission_id = http_response_body['data']['measurementSet']['submissionId']
            measurement_set_id = http_response_body['data']['measurementSet']['id']
          elsif http_response_body['error'] and http_response_body['error']['type'] == 'DuplicateEntryError'
            # TODO entry exists so store submission id, get submission, save measurement_set_id for categories
            submission_id = http_response_body['error']['details'][0]['submissionId']

          elsif http_response_body['error']
            error_type = http_response_body['error']['type']
            response.response_errors.create(:error_type => "#{category}: #{error_type}",
                                            :message => http_response_body['error']['message'])
            if http_response_body['error']['details']
              http_response_body['error']['details'].each do |error_detail|
                if error_detail['message']
                  response.response_errors.create(:error_type => "#{category}: #{error_type}", :message => error_detail['message'])
                end
              end
            end
          elsif http_response_body['error'] and http_response_body['message']
            response.response_errors.create(:error_type => "#{category}: #{http_response_body['error']}",
                                            :message => http_response_body['message'])
          else
            # not sure what the response is
          end
        end
      end
    else
      # Empty object
    end
  end

  def suncoast_submit_api_department(department, attestation_clinic_id, event_id)
    body_set = qpp_submission_object_department(department, attestation_clinic_id, event_id)
    if body_set.size > 0
      fiscal_year = AttestationRequirementFiscalYear.find_by_name(body_set[:performanceYear])
      if department.group_id == @selected_group_id and fiscal_year and body_set[:nationalProviderIdentifier]
        Response.destroy_all(:attestation_clinic_id => attestation_clinic_id,
                             :npi => body_set[:nationalProviderIdentifier],
                             :attestation_requirement_fiscal_year_id => fiscal_year.id)
        response = Response.create(:attestation_clinic_id => attestation_clinic_id,
                                   :tin => body_set[:taxpayerIdentificationNumber],
                                   :npi => body_set[:nationalProviderIdentifier],
                                   :attestation_requirement_fiscal_year_id => fiscal_year.id)

        base_api = 'https://suncoastapi.herokuapp.com/apisc/processqpp'
        uri = URI.parse(base_api)
        token = ApplicationConfiguration.get_token
        request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json')
        request.body = JSON.generate(body_set)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http_response = http.request(request)
        begin
          http_response_body = JSON.parse(http_response.body)
        rescue JSON::ParserError
          http_response_body = {'error' => 'Response is not JSON', 'message' => http_response.body.to_s}
        end

        if http_response_body['response'] and http_response_body['response'] == 'OK'
          # api submission was good!
        elsif http_response_body['errors'] and http_response_body['errors'].size > 0
          http_response_body['errors'].each do |error|
            error_type = error['detail']['error']['type']

            if error['detail']['error']['details'] and error['detail']['error']['details'].size > 0
              error['detail']['error']['details'].each do |error_detail|
                response.response_errors.create(:error_type => error_type, :message => error_detail['message'])
              end
            else
              response.response_errors.create(:error_type => error_type, :message => error['detail']['error']['message'])
            end
          end
        elsif http_response_body['error'] and http_response_body['message']
          response.response_errors.create(:error_type => http_response_body['error'],
                                          :message => http_response_body['message'])
        else
          # not sure what the response is
        end
      end
    else
      # Empty object
    end
  end

  def aci_measurement_set_json(department, attestation_clinic_id, event_id)
    # build json obj for aci
  end

  def quality_measurement_set_json(department, attestation_clinic_id, event_id)
    # build json obj for quality
  end

  def cpia_measurement_set_json(department, attestation_clinic_id, event_id)
    # build json obj for cpia
  end

  def requirement_to_json(department_criterion_requirement)
    requirement_json = nil
    requirement = department_criterion_requirement.x_group_requirement.requirement
    if requirement.metric_type
      measure_id = requirement.requirement_identifier
      req_id_prefix = measure_id.slice(0...measure_id.index('_').to_i)
      if department_criterion_requirement.exclusion_flag == 1 and measure_id == "#{req_id_prefix}_TRANS_EP_1"
        measure_id = "#{req_id_prefix}_TRANS_LVPP_1"
        value = true
      elsif department_criterion_requirement.exclusion_flag == 1 and measure_id == "#{req_id_prefix}_TRANS_HIE_1"
        measure_id = "#{req_id_prefix}_TRANS_LVOTC_1"
        value = true
      elsif department_criterion_requirement.exclusion_flag == 1 and measure_id == "#{req_id_prefix}_EP_1"
        measure_id = "#{req_id_prefix}_LVPP_1"
        value = true
      elsif department_criterion_requirement.exclusion_flag == 1 and measure_id == "#{req_id_prefix}_HIE_1"
        measure_id = "#{req_id_prefix}_LVOTC_1"
        value = true
      elsif department_criterion_requirement.exclusion_flag == 1 and measure_id == "#{req_id_prefix}_HIE_2"
        measure_id = "#{req_id_prefix}_LVITC_1"
        value = true
      elsif department_criterion_requirement.exclusion_flag == 1 and measure_id == "#{req_id_prefix}_HIE_4"
        measure_id = "#{req_id_prefix}_LVITC_2"
        value = true
        # The commented lines below would replace the above if's
        # if department_criterion_requirement.exclusion_flag == 1 and ['_TRANS_EP_1', '_TRANS_HIE_1', '_EP_1', '_HIE_1', '_HIE_2'].include?(measure_id.slice(measure_id.index('_')..-1))
        #   measure_id = requirement.exclusion_number
        #   value = true
      elsif department_criterion_requirement.exclusion_flag == 1 and %w[_PHCDRR_1 _PHCDRR_2 _PHCDRR_3 _PHCDRR_4 _PHCDRR_5].include?(measure_id.slice(measure_id.index('_')..-1))
        measure_id = requirement.exclusion_number
        value = true
      elsif department_criterion_requirement.exclusion2_flag == 1 and %w[_PHCDRR_1 _PHCDRR_2 _PHCDRR_3 _PHCDRR_4 _PHCDRR_5].include?(measure_id.slice(measure_id.index('_')..-1))
        measure_id = requirement.exclusion2_number
        value = true
      elsif department_criterion_requirement.exclusion3_flag == 1 and %w[_PHCDRR_1 _PHCDRR_2 _PHCDRR_3 _PHCDRR_4 _PHCDRR_5].include?(measure_id.slice(measure_id.index('_')..-1))
        measure_id = requirement.exclusion3_number
        value = true
      else
        value = requirement_value_to_json(department_criterion_requirement, requirement)
      end
      unless value.nil?
        requirement_json = {:measureId => measure_id,
                            :value => value}
      end
    end
    requirement_json
  end

  def requirement_value_to_json(department_criterion_requirement, requirement)
    case requirement.metric_type_id
      when 1 # Boolean
        value = (requirement.criterion_id == 5 ? (department_criterion_requirement.cpia_select_flag) : (department_criterion_requirement.numerator == 1))
        value
      when 2 # Proportion
        {:numerator => department_criterion_requirement.numerator,
         :denominator => department_criterion_requirement.denominator}
      when 3 # Non-Proportion
        value = {:numerator => department_criterion_requirement.numerator,
                 :denominator => department_criterion_requirement.denominator,
                 :isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
                 :observationInstances => department_criterion_requirement.denominator}
        value[:numeratorExclusion] = department_criterion_requirement.numerator_exclusion unless department_criterion_requirement.numerator_exclusion.nil?
        value[:denominatorException] = department_criterion_requirement.denominator_exception unless department_criterion_requirement.denominator_exception.nil?
        value
      when 4 # Single-Performance Rate
        if department_criterion_requirement.performance_met.nil? and department_criterion_requirement.performance_not_met.nil? and department_criterion_requirement.eligible_population.nil?
          value = {:isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
                   :performanceMet => department_criterion_requirement.numerator,
                   :performanceNotMet => (department_criterion_requirement.denominator.to_i - department_criterion_requirement.numerator.to_i),
                   :eligiblePopulation => department_criterion_requirement.denominator}
        else
          value = {:isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
                   :performanceMet => department_criterion_requirement.performance_met,
                   :performanceNotMet => department_criterion_requirement.performance_not_met,
                   :eligiblePopulation => department_criterion_requirement.eligible_population}
          value[:eligible_population_exclusion] = department_criterion_requirement.eligible_population_exclusion unless department_criterion_requirement.eligible_population_exclusion.nil?
          value[:eligible_population_exception] = department_criterion_requirement.eligible_population_exception unless department_criterion_requirement.eligible_population_exception.nil?
        end
        value
      when 5 # Multi-Performance Rate
        strata = []
        department_criterion_requirement.child_requirements_for_submission_json.each do |stratum_req|
          if stratum_req.performance_met.nil? and stratum_req.performance_not_met.nil? and stratum_req.eligible_population.nil?
            stratum_value = {:stratum => stratum_req.stratum_name,
                             :performanceMet => stratum_req.numerator,
                             :performanceNotMet => (stratum_req.denominator.to_i - stratum_req.numerator.to_i),
                             :eligiblePopulation => stratum_req.denominator}
          else
            stratum_value = {:stratum => stratum_req.stratum_name,
                             :performanceMet => stratum_req.performance_met,
                             :performanceNotMet => stratum_req.performance_not_met,
                             :eligiblePopulation => stratum_req.eligible_population}
            stratum_value[:eligible_population_exclusion] = stratum_req.eligible_population_exclusion unless stratum_req.eligible_population_exclusion.nil?
            stratum_value[:eligible_population_exception] = stratum_req.eligible_population_exception unless stratum_req.eligible_population_exception.nil?
          end
          strata << stratum_value
        end
        {:isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
         :strata => strata}
      when 6 # Registry Single-Performance Rate
        if department_criterion_requirement.performance_met.nil? and department_criterion_requirement.performance_not_met.nil? and department_criterion_requirement.eligible_population.nil?
          value = {:isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
                   :performanceMet => department_criterion_requirement.numerator,
                   :performanceNotMet => (department_criterion_requirement.denominator.to_i - department_criterion_requirement.numerator.to_i),
                   :eligiblePopulation => department_criterion_requirement.denominator,
                   :performanceRate => department_criterion_requirement.performance_rate}
        else
          value = {:isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
                   :performanceMet => department_criterion_requirement.performance_met,
                   :performanceNotMet => department_criterion_requirement.performance_not_met,
                   :eligiblePopulation => department_criterion_requirement.eligible_population,
                   :performanceRate => department_criterion_requirement.performance_rate}
          value[:eligible_population_exclusion] = department_criterion_requirement.eligible_population_exclusion unless department_criterion_requirement.eligible_population_exclusion.nil?
          value[:eligible_population_exception] = department_criterion_requirement.eligible_population_exception unless department_criterion_requirement.eligible_population_exception.nil?
        end
        value
      when 7 # Registry Multi-Performance Rate
        strata = []
        department_criterion_requirement.child_requirements_for_submission_json.each do |stratum_req|
          if stratum_req.performance_met.nil? and stratum_req.performance_not_met.nil? and stratum_req.eligible_population.nil?
            stratum_value = {:stratum => stratum_req.stratum_name,
                             :performanceMet => stratum_req.numerator,
                             :performanceNotMet => (stratum_req.denominator.to_i - stratum_req.numerator.to_i),
                             :eligiblePopulation => stratum_req.denominator}
          else
            stratum_value = {:stratum => stratum_req.stratum_name,
                             :performanceMet => stratum_req.performance_met,
                             :performanceNotMet => stratum_req.performance_not_met,
                             :eligiblePopulation => stratum_req.eligible_population}
            stratum_value[:eligible_population_exclusion] = stratum_req.eligible_population_exclusion unless stratum_req.eligible_population_exclusion.nil?
            stratum_value[:eligible_population_exception] = stratum_req.eligible_population_exception unless stratum_req.eligible_population_exception.nil?
          end
          strata << stratum_value
        end
        {:isEndToEndReported => department_criterion_requirement.end_to_end_cehrt_flag.nil? ? false : department_criterion_requirement.end_to_end_cehrt_flag,
         :performanceRate => department_criterion_requirement.performance_rate,
         :strata => strata}
      else
        nil
    end
  end

  def stream_json(filename, file_content)
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'application/json'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end

    render(:text => JSON.pretty_generate(file_content))
    # begin
    #   render(:text => JSON.generate(file_content))
    # rescue ArgumentError => e
    #   render(:text => file_content.inspect)
    # end
  end

  def determine_fiscal_year_based_on_current_date(group_type)
    current_time = Time.zone.now
    temp_fiscal_year = current_time.year
    if group_type.id == 2
      if current_time.month.to_i >= group_type.fiscal_start.to_s[1..2].to_i
        temp_fiscal_year += 1
      end
    end
    return temp_fiscal_year
  end
  def resolve_layout
    # "portal" + ((@selected_mum_program_view == 2) ? @selected_group.theme.layout_name : '')
    "portal"
  end
  def resolve_pop_up_layout
    "pop_up" + ((@selected_mum_program_view == 2) ? @selected_group.theme.layout_name : '')
  end
end
