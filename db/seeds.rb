# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

  create_authorization_levels = false     # make true if ifa_pilot needs to be restored again
  update_authorization_levels = false

  create_applicable_scopes = false     # make true if ifa_pilot needs to be restored again
  update_applicable_scopes = false

  initialize_master_app_provider = false     # make true if ifa_pilot needs to be restored again

  create_a_resource_type = false

  create_object_type = false

  initialize_act_sat_map = false     # make true if act_sat_map needs to be restored again

  create_ifa_standards = false

  add_act_subject = false

  add_subject_area = false

  deactivate_content_types = false

  add_benchmark_types = false

  add_dashboard_cell_id = false

  update_assessment_stats = false

  create_default_strategies = false

  add_default_question_strategy = false

  set_default_question_times = false

  set_default_english_question_strategy = false

  if set_default_english_question_strategy
    ew_subject = ActSubject.ew
    if !ew_subject.nil?
      default_id = ew_subject.act_strategies.default.id rescue nil
      strategy_id = ew_subject.act_strategies.with_name('Sentence Structure, Punctuation, Usage').first.id rescue  default_id
      ew_subject.act_questions.select{|q| q.strand.abbrev.upcase == 'COP'}.each do |question|
        question.update_attributes({'act_strategy_id' => strategy_id})
      end
      ew_subject.act_questions.select{|q| q.strand.abbrev.upcase == 'COU'}.each do |question|
        question.update_attributes({'act_strategy_id' => strategy_id})
      end
      ew_subject.act_questions.select{|q| q.strand.abbrev.upcase == 'SS&F'}.each do |question|
        question.update_attributes({'act_strategy_id' => strategy_id})
      end
      strategy_id = ew_subject.act_strategies.with_name('Organization').first.id rescue default_id
      ew_subject.act_questions.select{|q| q.strand.abbrev.upcase == 'OU&C'}.each do |question|
        question.update_attributes({'act_strategy_id' => strategy_id})
      end
      strategy_id = ew_subject.act_strategies.with_name('Word Choice').first.id rescue default_id
      ew_subject.act_questions.select{|q| q.strand.abbrev.upcase == 'WCTSTCE'}.each do |question|
        question.update_attributes({'act_strategy_id' => strategy_id})
      end
      strategy_id = ew_subject.act_strategies.with_name('Topic Development').first.id rescue default_id
      ew_subject.act_questions.select{|q| q.strand.abbrev.upcase == 'TDTPF'}.each do |question|
        question.update_attributes({'act_strategy_id' => strategy_id})
      end
    end
  end

  if set_default_question_times
    ActQuestion.all.each do |question|
      if question.allotted_time == 0
        question.update_attributes({'allotted_time' => question.act_subject.question_time})
      end
    end
  end

  if create_default_strategies
    ActSubject.no_na.each do |subject|
      if subject.act_strategies.default.nil?
        ActStrategy.create({'name' => 'No Strategy Needed', 'pos' => 0, 'is_active'=>1, 'is_default'=>1,
                           'description'=> 'This indicates when a strategy is/was not necessary or possible to answer a question.',
                           'act_subject_id'=> subject.id})
      end
    end
  end

  if add_default_question_strategy
    ActQuestion.all.each do |question|
      if question.act_strategy.nil? && !question.act_subject.nil? && !question.act_subject.act_strategies.default.nil?
        question.update_attributes({'act_strategy_id' => question.act_subject.act_strategies.default.id})
      end
    end
  end

  if update_assessment_stats
     ActAssessment.all.each do |ass|
       subs = ass.act_submissions.final.select{|s| s.authentic?}
       cum_subs = subs.size
       cum_ques = ass.questions_for_test.size * cum_subs
       cum_choices = subs.map{|s| s.tot_choices}.sum
       cum_points = subs.map{|s| s.tot_points}.sum
       cum_duration = subs.map{|s| s.duration}.sum
       ass.update_attributes('cum_submissions' => cum_subs, 'cum_questions_asked' => cum_ques, 'cum_choices_made' => cum_choices,
       'cum_points_earned' => cum_points, 'cum_duration' => cum_duration)
       if !subs.empty?
        shortest_time = subs.map{|s| s.duration}.min
        best_time_point = subs.map{|s| (s.tot_points > 0.0 ? (s.duration.to_f/s.tot_points).round : 18000)}.min
        best_pct = subs.map{|s| (100.0 * s.tot_points/s.tot_choices.to_f).round}.max
        most_points = subs.map{|s| s.tot_points}.max
        answer_rate = subs.map{|s| (s.duration.to_f/s.tot_choices.to_f).round}.min
        most_answers = [subs.map{|s| s.tot_choices}.max, ass.questions_for_test.size].min
       else
         shortest_time = 18000
         best_time_point = 18000
         best_pct = 0
         most_points = 0.0
         answer_rate = 18000
         most_answers = 0
       end
       ass.update_attributes('shortest_duration' => shortest_time, 'best_time_per_point' => best_time_point, 'best_pct' => best_pct,
        'most_points' => most_points, 'best_answer_rate' => answer_rate, 'most_answered' => most_answers)
     end
  end


  if add_dashboard_cell_id
    IfaDashboardCell.all.each do |db_cell|
      db_cell.update_attributes('cell' => (db_cell.act_score_range_id.to_s + '|' + db_cell.act_standard_id.to_s))
    end
  end

  if add_benchmark_types
    # did for tcpj 9/25/17
#    ActBenchType.create({'name' => 'evidence', 'standard' => 'act', 'act_master_id' => 1, 'for_resource_panel' => 1, 'for_dash_board' => 1,
#                             'for_list' => 1, 'for_static' => 1, 'long_name' => 'Evidence Outcome', 'description' => 'What must be demonstated or achieved.'})
#    ActBenchType.create({'name' => 'exemplar', 'standard' => 'act', 'act_master_id' => 1, 'for_resource_panel' => 1, 'for_dash_board' => 1,
#                             'for_list' => 1, 'for_static' => 1, 'long_name' => 'Example', 'description' => 'An example explaining the benchmark.'})
    ActBenchType.all.each do |t|
      if t.name == 'benchmark'
        t.update_attributes('abbrev' => 'B')
      elsif t.name == 'suggestion'
        t.update_attributes('abbrev' => 'S')
      elsif t.name == 'evidence'
        t.update_attributes('abbrev' => 'E')
      elsif t.name == 'improvement'
        t.update_attributes('name' => 'suggestion', 'abbrev' => 'S')
      elsif t.name == 'exemplar'
        t.update_attributes('abbrev' => 'X')
      end
    end
  end

  if deactivate_content_types
    # did for tcpj 9/25/17
    ContentObjectTypeGroup.find_by_name('VIDEO').update_attributes(:is_active => false)
    ContentObjectTypeGroup.find_by_name('COMPRESSED').update_attributes(:is_active => false)
    ContentObjectTypeGroup.find_by_name('AUDIO').update_attributes(:is_active => false)
    ContentObjectTypeGroup.find_by_name('EMBED CODE').update_attributes(:name => 'VIDEO STREAM', :content_format => 'Text Block')
    ContentObjectTypeGroup.find_by_name('LINK').update_attributes(:content_format => 'String')
  end

  if add_act_subject
    # did for tcpj 9/25/17
    ActSubject.create({'name' => 'Geometry/Measurement/Statistics', 'is_plannable' => 1})
  end

  if add_subject_area
    SubjectArea.find_by_name('Geometry').update_attributes('name' => 'Geom/Measrmnt/Stat', 'act_subject_id' => ActSubject.math_geo_stat.id)
    SubjectArea.find_by_name('Statistics').update_attributes('act_subject_id' => ActSubject.math_geo_stat.id)
    SubjectArea.find_by_name('Algebra').update_attributes('name' => 'Nmbrs/Algebra/Funcs', 'act_subject_id' => ActSubject.math_number.id)
  end

  if create_ifa_standards


    ActMaster.find_by_id(1).update_attributes('name' => 'Precision Growth Model', 'abbrev' => 'PP',
                               'source' => 'Precision School Improvement', 'abbrev_old' => 'ACT',
                               'is_national' => 1, 'is_default' => 1)

    ActMaster.find_by_id(2).update_attributes('name' => 'Colorado State Education Standards', 'abbrev' => 'CO',
                      'source' => 'http://www.cde.state.co.us/cdeassess/UAS/CoAcademicStandards.html', 'abbrev_old' => 'CO',
                      'is_national' => 0, 'is_default' => 0)

    ActMaster.find_by_id(3).update_attributes('name' => 'Common Core Standards', 'abbrev' => 'CC',
                      'source' => 'http://www.corestandards.org', 'abbrev_old' => 'CC',
                      'is_national' => 1, 'is_default' => 0)

    ActMaster.create({'name' => 'ACT College Readiness Standards', 'abbrev' => 'ACTNEW',
                      'source' => 'http://www.precisionschoolimprovement.com/', 'abbrev_old' => 'PP',
                      'is_national' => 1, 'is_default' => 0})
  end


  if initialize_act_sat_map
    ActSatMap.destroy_all
    #  ACT English & Writing
    ActMaster.act_std.act_score_ranges.for_subject(ActSubject.ew).each do |act_range|
      if act_range.sat_range
        act_range.sat_range.destroy
      end
      if act_range.range == '33-36'
        sat_map = ActSatMap.create('range' => '730-800', 'lower_score' => 730, 'upper_score' => 800)
      elsif act_range.range == '28-32'
        sat_map = ActSatMap.create('range' => '620-720', 'lower_score' => 620, 'upper_score' => 720)
      elsif act_range.range == '24-27'
        sat_map = ActSatMap.create('range' => '550-610', 'lower_score' => 550, 'upper_score' => 610)
      elsif act_range.range == '20-23'
        sat_map = ActSatMap.create('range' => '470-540', 'lower_score' => 470, 'upper_score' => 540)
      elsif act_range.range == '16-19'
        sat_map = ActSatMap.create('range' => '390-460', 'lower_score' => 390, 'upper_score' => 460)
      elsif act_range.range == '13-15'
        sat_map = ActSatMap.create('range' => '340-380', 'lower_score' => 340, 'upper_score' => 380)
      elsif act_range.range == '1-12'
        sat_map = ActSatMap.create('range' => '300-330', 'lower_score' => 300, 'upper_score' => 330)
      end
      unless sat_map.nil?
        act_range.update_attributes({'act_sat_map_id' => sat_map.id})
      end
    end
    #  ACT Math
    ActMaster.act_std.act_score_ranges.for_subject(ActSubject.math).each do |act_range|
      if act_range.sat_range
        act_range.sat_range.destroy
      end
      if act_range.range == '33-36'
        sat_map = ActSatMap.create('range' => '720-800', 'lower_score' => 720, 'upper_score' => 800)
      elsif act_range.range == '28-32'
        sat_map = ActSatMap.create('range' => '630-710', 'lower_score' => 630, 'upper_score' => 710)
      elsif act_range.range == '24-27'
        sat_map = ActSatMap.create('range' => '550-620', 'lower_score' => 550, 'upper_score' => 620)
      elsif act_range.range == '20-23'
        sat_map = ActSatMap.create('range' => '470-540', 'lower_score' => 470, 'upper_score' => 540)
      elsif act_range.range == '16-19'
        sat_map = ActSatMap.create('range' => '390-460', 'lower_score' => 390, 'upper_score' => 460)
      elsif act_range.range == '13-15'
        sat_map = ActSatMap.create('range' => '310-380', 'lower_score' => 310, 'upper_score' => 380)
      elsif act_range.range == '1-12'
        sat_map = ActSatMap.create('range' => '250-300', 'lower_score' => 250, 'upper_score' => 300)
      end
      unless sat_map.nil?
        act_range.update_attributes({'act_sat_map_id' => sat_map.id})
      end
    end
    #  ACT Reading
    ActMaster.act_std.act_score_ranges.for_subject(ActSubject.rl).each do |act_range|
      if act_range.sat_range
        act_range.sat_range.destroy
      end
      if act_range.range == '33-36'
        sat_map = ActSatMap.create('range' => '720-800', 'lower_score' => 720, 'upper_score' => 800)
      elsif act_range.range == '28-32'
        sat_map = ActSatMap.create('range' => '630-710', 'lower_score' => 630, 'upper_score' => 710)
      elsif act_range.range == '24-27'
        sat_map = ActSatMap.create('range' => '550-620', 'lower_score' => 550, 'upper_score' => 620)
      elsif act_range.range == '20-23'
        sat_map = ActSatMap.create('range' => '470-540', 'lower_score' => 470, 'upper_score' => 540)
      elsif act_range.range == '16-19'
        sat_map = ActSatMap.create('range' => '390-460', 'lower_score' => 390, 'upper_score' => 460)
      elsif act_range.range == '13-15'
        sat_map = ActSatMap.create('range' => '310-380', 'lower_score' => 310, 'upper_score' => 380)
      elsif act_range.range == '1-12'
        sat_map = ActSatMap.create('range' => '250-300', 'lower_score' => 250, 'upper_score' => 300)
      end
      unless sat_map.nil?
        act_range.update_attributes({'act_sat_map_id' => sat_map.id})
      end
    end
    #  ACT Science
    ActMaster.act_std.act_score_ranges.for_subject(ActSubject.science).each do |act_range|
      if act_range.sat_range
        act_range.sat_range.destroy
      end
      if act_range.range == '33-36'
        sat_map = ActSatMap.create('range' => '720-800', 'lower_score' => 720, 'upper_score' => 800)
      elsif act_range.range == '28-32'
        sat_map = ActSatMap.create('range' => '630-710', 'lower_score' => 630, 'upper_score' => 710)
      elsif act_range.range == '24-27'
        sat_map = ActSatMap.create('range' => '550-620', 'lower_score' => 550, 'upper_score' => 620)
      elsif act_range.range == '20-23'
        sat_map = ActSatMap.create('range' => '470-540', 'lower_score' => 470, 'upper_score' => 540)
      elsif act_range.range == '16-19'
        sat_map = ActSatMap.create('range' => '390-460', 'lower_score' => 390, 'upper_score' => 460)
      elsif act_range.range == '13-15'
        sat_map = ActSatMap.create('range' => '310-380', 'lower_score' => 310, 'upper_score' => 380)
      elsif act_range.range == '1-12'
        sat_map = ActSatMap.create('range' => '250-300', 'lower_score' => 250, 'upper_score' => 300)
      end
      unless sat_map.nil?
        act_range.update_attributes({'act_sat_map_id' => sat_map.id})
      end
    end
  end

  if create_object_type
    if ContentObjectType.where(['content_object_type =?', 'XLSM']).empty?
      ContentObjectType.create('content_object_type' => 'XLSM', 'content_object_type_group_id' => 8,
                                'name' => 'MS Excel Spreadsheet', 'mime_type' => 'application/vnd.ms-excel',
                                'is_nested_content' => false)
    end
  end

  if create_a_resource_type
  #  if ContentResourceType.where(['name =?', 'Budget']).empty?
  #    ContentResourceType.create('name' => 'Budget', 'descript' => 'Budget Document')
  #  end
  #  if ContentResourceType.where(['name =?', 'Proposal']).empty?
  #    ContentResourceType.create('name' => 'Proposal', 'descript' => 'Proposal Document')
  #  end
  #  if ContentResourceType.where(['name =?', 'Evidence']).empty?
  #    ContentResourceType.create('name' => 'Evidence', 'descript' => 'Performance Evidence')
  #  end
    if ContentResourceType.where(['name =?', 'Testing Tip/Strategy']).empty?
      ContentResourceType.create('name' => 'Testing Tip/Strategy', 'descript' => 'An SAT, or other, Test Tip.')
    end
  end

  if initialize_master_app_provider
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.core.id, CoopApp.core.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.core.id, 'organization_id' => CoopApp.core.owner.id,
                                'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                'alt_name' => 'Core System', 'alt_abbrev' => 'CORE', 'provider_id' => CoopApp.core.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.classroom.id, CoopApp.classroom.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.classroom.id, 'organization_id' => CoopApp.classroom.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Knowledge Management', 'alt_abbrev' => 'KM', 'provider_id' => CoopApp.classroom.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.ifa.id, CoopApp.ifa.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.ifa.id, 'organization_id' => CoopApp.ifa.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Integrated Formative Assessment', 'alt_abbrev' => 'IFA', 'provider_id' => CoopApp.ifa.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.ita.id, CoopApp.ita.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.ita.id, 'organization_id' => CoopApp.ita.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Teacher Assess', 'alt_abbrev' => 'ITA', 'provider_id' => CoopApp.ita.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.blog.id, CoopApp.blog.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.blog.id, 'organization_id' => CoopApp.blog.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Panel Blogs', 'alt_abbrev' => 'BLOGS', 'provider_id' => CoopApp.blog.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.ctl.id, CoopApp.ctl.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.ctl.id, 'organization_id' => CoopApp.ctl.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Collaborative Time In Learning', 'alt_abbrev' => 'CTL', 'provider_id' => CoopApp.ctl.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.pd.id, CoopApp.pd.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.pd.id, 'organization_id' => CoopApp.pd.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Integrated PD', 'alt_abbrev' => 'IPD', 'provider_id' => CoopApp.pd.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.stat.id, CoopApp.stat.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.stat.id, 'organization_id' => CoopApp.stat.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'School Time Analysis', 'alt_abbrev' => 'STAT', 'provider_id' => CoopApp.stat.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.cm.id, CoopApp.cm.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.cm.id, 'organization_id' => CoopApp.cm.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Client Management', 'alt_abbrev' => 'CM', 'provider_id' => CoopApp.cm.owner.id)
    end
    if CoopAppOrganization.where(["coop_app_id = ? AND organization_id = ?", CoopApp.elt.id, CoopApp.elt.owner.id]).empty?
      CoopAppOrganization.create('coop_app_id' => CoopApp.elt.id, 'organization_id' => CoopApp.elt.owner.id,
                                 'is_owner' => true, 'is_selected' => true, 'is_allowed' => true,
                                 'alt_name' => 'Performance Monitoring', 'alt_abbrev' => 'PM', 'provider_id' => CoopApp.elt.owner.id)
    end
  end

  if create_authorization_levels
#  Assumes AuthorizationLevel Table was dropped then recreated

    # AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 1,
    #                           'description' => 'Core System Administrator',
    #                           'explanation' => 'All access, everywhere,  all the time.'})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'administrator', 'coop_app_id' => 1,
    #                          'description' => 'Organization System Administrator',
    #                          'explanation' => 'User can perform all system adminstration functions for the organization.'})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'friend', 'coop_app_id' => 1,
    #                          'description' => 'Friend of an Affiliate',
    #                          'explanation' => "This identifies the users who have an affiliation with the organization.
    #                          Each user either tagged the organization or identified the organization when registering."})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'knowledge_manager', 'coop_app_id' => 1,
    #                          'description' => 'Resource Library Contributor',
    #                          'explanation' => "This allows the user to add resources to the commont resource library."})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'administrator', 'coop_app_id' => 2,
    #                          'description' => "Offering Administrator",
    #                          'explanation' => "This allows the user to manage all of the organization's class offerings as though the user were a teacher for them all.
    #                          It also allows the user to create new offerings, define the section/periods for each offering, and assign teachers to each section/period."})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'teacher', 'coop_app_id' => 2,
    #                          'description' => "Teacher",
    #                          'explanation' => "This designates the user as a teacher for a particular class offering."})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'student', 'coop_app_id' => 2,
    #                          'description' => "Student",
    #                          'explanation' => "This designates the user as a student for a particular class offering."})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'favorite', 'coop_app_id' => 1,
    #                          'description' => "Favorite Scope ID",
    #                          'explanation' => "This tags an entity, such as a class offering, or library resource, as a favorite of a user."})
    #
    # AuthorizationLevel.create({
    #                          'name' => 'colleague', 'coop_app_id' => 1,
    #                          'description' => "Colleague of a User",
    #                          'explanation' => "This establishes connections between User to faciliate resource exchanges."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'beta_user', 'coop_app_id' => 1,
    #                           'description' => "Beta Project Participant",
    #                           'explanation' => "This desginates the user as a beta project participant, giving the user access to features related to a
    #                           particular project and not available to users not involved with the project."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 3,
    #                           'description' => "Integrated Formative Assessment Administrator",
    #                           'explanation' => "This gives the user administrative authority for the Integrated Formative Assessment (IFA) application.
    #                           User can adjust IFA configuration options, manage assessment repositories, and view IFA dashboards."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 4,
    #                           'description' => "Integrated Teacher Assessment Administrator",
    #                           'explanation' => "This gives the user administrative authority for the Integrated Teacher Assessment (ITA) application.
    #                           User can specify teacher metrics to be gathered for the organization."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'panelist', 'coop_app_id' => 5,
    #                           'description' => "Blogger For The Organization",
    #                           'explanation' => "User is a blog panalist. User will be able to post to blogs discussions for which he is identified as a panelist."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'observer', 'coop_app_id' => 6,
    #                           'description' => "Collaborative Time & Learning Observer",
    #                           'explanation' => "This designates the user as a classroom observer. User will be able to conduct Time & Learning observations for any of the organization's class offerings."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 6,
    #                           'description' => "Collaborative Time & Learning Administrator",
    #                           'explanation' => "This gives the user administrative authority for the Collaborative Time & Learning (CTL) application.
    #                           User can specify CTL configuration options, create/issue Surveys, and view all CTL dashboards."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'teacher', 'coop_app_id' => 1,
    #
    #                           'description' => "Org Teacher",
    #                           'explanation' => "This identifies the user as a teacher who can be assigned a section/period
    #                           for any of the organization's class offerings."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 7,
    #                           'description' => "Professional Development Administrator",
    #                           'explanation' => "This gives the user administrative authority for the Discover Action & Learning Process (DALP) professional development methodology.
    #                           User can specify DALP configuration options, create/issue surveys, and view all DALP dashboards."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 6,
    #                           'description' => "CTL Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 8,
    #                           'description' => "School Time Analysis Admin",
    #                           'explanation' => "This gives the user administrative authority for the Integrated School Time Analysis application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'user', 'coop_app_id' => 8,
    #                           'description' => "School Time Analysis User",
    #                           'explanation' => "This gives the user authority use the Integrated School Time Analysis application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 9,
    #                           'description' => "Client Management Administrator",
    #                           'explanation' => "This gives the user Administrator authority for the Client Management application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'knowledge_manager', 'coop_app_id' => 9,
    #                           'description' => "Knowledge Manager",
    #                           'explanation' => "This gives the user Knowledge Manager authority for the Client Management application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'consultant', 'coop_app_id' => 9,
    #                           'description' => "Consultant",
    #                           'explanation' => "This gives the user Consultant authority for the Client Management application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 10,
    #                           'description' => "ELT Administrator",
    #                           'explanation' => "This gives the user Administrator authority for the ELT application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'user', 'coop_app_id' => 10,
    #                           'description' => "ELT User",
    #                           'explanation' => "This allows access to the ELT application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'library_administrator', 'coop_app_id' => 1,
    #                           'description' => "Resource Library Administrator",
    #                           'explanation' => "This allows the user to manage all library resources for the organization."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'reviewer', 'coop_app_id' => 10,
    #                           'description' => "ELT Case Reviewer",
    #                           'explanation' => "This allows the user to reiew and finalize all performance monitoring diagnostic cases."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'administrator', 'coop_app_id' => 5,
    #                           'description' => "Blog Administrator",
    #                           'explanation' => "This identifies the user as a blog administrator. User will be able to create and maintain the organization's blogs."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 7,
    #                           'description' => "PD Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 8,
    #                           'description' => "STAT Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 9,
    #                           'description' => "CM Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 10,
    #                           'description' => "ELT Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 2,
    #                           'description' => "Offering Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 3,
    #                           'description' => "IFA Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 4,
    #                           'description' => "ITA Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    #
    # AuthorizationLevel.create({
    #                           'name' => 'superuser', 'coop_app_id' => 5,
    #                           'description' => "Blog Application Superuser",
    #                           'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
    AuthorizationLevel.create({
                           'name' => 'superstudent', 'coop_app_id' => 3,
                           'description' => "IFA Super Student",
                           'explanation' => "This gives the user the ability to see the correct assessment questions."})
  end

   if create_applicable_scopes
     auth_level = AuthorizationLevel.find_by_name('superstudent') rescue nil
     if !auth_level.nil?
      ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => auth_level.id})
     end
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 2})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 3})
    # ApplicableScope.create({'name' => 'Classroom', 'authorization_level_id' => 8})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 4})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 5})
    # ApplicableScope.create({'name' => 'Classroom', 'authorization_level_id' => 6})
    # ApplicableScope.create({'name' => 'Classroom', 'authorization_level_id' => 7})
    # ApplicableScope.create({'name' => 'Content', 'authorization_level_id' => 8})
    # ApplicableScope.create({'name' => 'User', 'authorization_level_id' => 9})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 10})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 11})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 12})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 13})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 14})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 15})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 16})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 17})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 18})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 19})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 20})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 21})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 22})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 23})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 24})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 25})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 26})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 27})
    # ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 28})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 29})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 30})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 31})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 32})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 33})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 34})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 35})
    # ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 36})
  end

  if update_authorization_levels
    AuthorizationLevel.find_by_id(1).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 1,
                                'description' => 'Core System Administrator',
                                'explanation' => 'All access, everywhere,  all the time.'})

    AuthorizationLevel.find_by_id(2).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 1,
                                'description' => 'Organization System Administrator',
                                'explanation' => 'User can perform all system adminstration functions for the organization.'})

    AuthorizationLevel.find_by_id(3).update_attributes({
                                'name' => 'friend', 'coop_app_id' => 1,
                                'description' => 'Friend of an Affiliate',
                                'explanation' => "This identifies the users who have an affiliation with the organization.
                                Each user either tagged the organization or identified the organization when registering."})

    AuthorizationLevel.find_by_id(4).update_attributes({
                                'name' => 'knowledge_manager', 'coop_app_id' => 1,
                                'description' => 'Resource Library Contributor',
                                'explanation' => "This allows the user to add resources to the commont resource library."})

    AuthorizationLevel.find_by_id(5).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 2,
                                'description' => "Offering Administrator",
                                'explanation' => "This allows the user to manage all of the organization's class offerings as though the user were a teacher for them all.
                                It also allows the user to create new offerings, define the section/periods for each offering, and assign teachers to each section/period."})

    AuthorizationLevel.find_by_id(6).update_attributes({
                                'name' => 'teacher', 'coop_app_id' => 2,
                                'description' => "Teacher",
                                'explanation' => "This designates the user as a teacher for a particular class offering."})

    AuthorizationLevel.find_by_id(7).update_attributes({
                                'name' => 'student', 'coop_app_id' => 2,
                                'description' => "Student",
                                'explanation' => "This designates the user as a student for a particular class offering."})

    AuthorizationLevel.find_by_id(8).update_attributes({
                                 'name' => 'favorite', 'coop_app_id' => 1,
                                 'description' => "Favorite Scope ID",
                                 'explanation' => "This tags an entity, such as a class offering, or library resource, as a favorite of a user."})

    AuthorizationLevel.find_by_id(9).update_attributes({
                                 'name' => 'colleague', 'coop_app_id' => 1,
                                 'description' => "Colleague of a User",
                                 'explanation' => "This establishes connections between User to faciliate resource exchanges."})

    AuthorizationLevel.find_by_id(10).update_attributes({
                                 'name' => 'beta_user', 'coop_app_id' => 1,
                                 'description' => "Beta Project Participant",
                                 'explanation' => "This desginates the user as a beta project participant, giving the user access to features related to a
                                 particular project and not available to users not involved with the project."})

    AuthorizationLevel.find_by_id(11).update_attributes({
                                  'name' => 'administrator', 'coop_app_id' => 3,
                                  'description' => "Integrated Formative Assessment Administrator",
                                  'explanation' => "This gives the user administrative authority for the Integrated Formative Assessment (IFA) application.
                                  User can adjust IFA configuration options, manage assessment repositories, and view IFA dashboards."})

    AuthorizationLevel.find_by_id(12).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 4,
                                 'description' => "Integrated Teacher Assessment Administrator",
                                 'explanation' => "This gives the user administrative authority for the Integrated Teacher Assessment (ITA) application.
                                 User can specify teacher metrics to be gathered for the organization."})

    AuthorizationLevel.find_by_id(13).update_attributes({
                                  'name' => 'panelist', 'coop_app_id' => 5,
                                  'description' => "Blogger For The Organization",
                                  'explanation' => "User is a blog panalist. User will be able to post to blogs discussions for which he is identified as a panelist."})

    AuthorizationLevel.find_by_id(14).update_attributes({
                                  'name' => 'observer', 'coop_app_id' => 6,
                                  'description' => "Collaborative Time & Learning Observer",
                                  'explanation' => "This designates the user as a classroom observer. User will be able to conduct Time & Learning observations for any of the organization's class offerings."})

    AuthorizationLevel.find_by_id(15).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 6,
                                'description' => "Collaborative Time & Learning Administrator",
                                'explanation' => "This gives the user administrative authority for the Collaborative Time & Learning (CTL) application.
                                User can specify CTL configuration options, create/issue Surveys, and view all CTL dashboards."})

    AuthorizationLevel.find_by_id(16).update_attributes({
                                 'name' => 'teacher', 'coop_app_id' => 1,
                                 'description' => "Org Teacher",
                                 'explanation' => "This identifies the user as a teacher who can be assigned a section/period
                                 for any of the organization's class offerings."})

    AuthorizationLevel.find_by_id(17).update_attributes({
                                  'name' => 'administrator', 'coop_app_id' => 7,
                                  'description' => "Professional Development Administrator",
                                  'explanation' => "This gives the user administrative authority for the Discover Action & Learning Process (DALP) professional development methodology.
                                  User can specify DALP configuration options, create/issue surveys, and view all DALP dashboards."})

    AuthorizationLevel.find_by_id(18).update_attributes({
                                  'name' => 'superuser', 'coop_app_id' => 6,
                                  'description' => "CTL Application Superuser",
                                  'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(19).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 8,
                                'description' => "School Time Analysis Admin",
                                'explanation' => "This gives the user administrative authority for the Integrated School Time Analysis application."})

    AuthorizationLevel.find_by_id(20).update_attributes({
                                'name' => 'user', 'coop_app_id' => 8,
                                'description' => "School Time Analysis User",
                                'explanation' => "This gives the user authority use the Integrated School Time Analysis application."})

    AuthorizationLevel.find_by_id(21).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 9,
                                'description' => "Client Management Administrator",
                                'explanation' => "This gives the user Administrator authority for the Client Management application."})

    AuthorizationLevel.find_by_id(22).update_attributes({
                                'name' => 'knowledge_manager', 'coop_app_id' => 9,
                                'description' => "Knowledge Manager",
                                'explanation' => "This gives the user Knowledge Manager authority for the Client Management application."})

    AuthorizationLevel.find_by_id(23).update_attributes({
                                'name' => 'consultant', 'coop_app_id' => 9,
                                'description' => "Consultant",
                                'explanation' => "This gives the user Consultant authority for the Client Management application."})

    AuthorizationLevel.find_by_id(24).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 10,
                                'description' => "ELT Administrator",
                                'explanation' => "This gives the user Administrator authority for the ELT application."})

    AuthorizationLevel.find_by_id(25).update_attributes({
                                'name' => 'user', 'coop_app_id' => 10,
                                'description' => "ELT User",
                                'explanation' => "This allows access to the ELT application."})

    AuthorizationLevel.find_by_id(26).update_attributes({
                               'name' => 'library_administrator', 'coop_app_id' => 1,
                               'description' => "Resource Library Administrator",
                               'explanation' => "This allows the user to manage all library resources for the organization."})

    AuthorizationLevel.find_by_id(27).update_attributes({
                              'name' => 'reviewer', 'coop_app_id' => 10,
                              'description' => "ELT Case Reviewer",
                              'explanation' => "This allows the user to reiew and finalize all performance monitoring diagnostic cases."})

    AuthorizationLevel.find_by_id(28).update_attributes({
                              'name' => 'administrator', 'coop_app_id' => 5,
                              'description' => "Blog Administrator",
                              'explanation' => "This identifies the user as a blog administrator. User will be able to create and maintain the organization's blogs."})

    AuthorizationLevel.find_by_id(29).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 7,
                                'description' => "PD Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(30).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 8,
                                'description' => "STAT Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(31).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 9,
                                'description' => "CM Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(32).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 10,
                                'description' => "ELT Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(33).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 2,
                                'description' => "Offering Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(34).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 3,
                                'description' => "IFA Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(35).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 4,
                                'description' => "ITA Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(36).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 5,
                                'description' => "Blog Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
  end

  if update_applicable_scopes
    ApplicableScope.find_by_id(1).update_attributes({'name' => 'Organization', 'authorization_level_id' => 2})
    ApplicableScope.find_by_id(2).update_attributes({'name' => 'Organization', 'authorization_level_id' => 3})
    ApplicableScope.find_by_id(3).update_attributes({'name' => 'Classroom', 'authorization_level_id' => 8})
    ApplicableScope.find_by_id(4).update_attributes({'name' => 'Organization', 'authorization_level_id' => 4})
    ApplicableScope.find_by_id(5).update_attributes({'name' => 'Organization', 'authorization_level_id' => 5})
    ApplicableScope.find_by_id(6).update_attributes({'name' => 'Classroom', 'authorization_level_id' => 6})
    ApplicableScope.find_by_id(7).update_attributes({'name' => 'Classroom', 'authorization_level_id' => 7})
    ApplicableScope.find_by_id(8).update_attributes({'name' => 'Content', 'authorization_level_id' => 8})
    ApplicableScope.find_by_id(9).update_attributes({'name' => 'User', 'authorization_level_id' => 9})
    ApplicableScope.find_by_id(10).update_attributes({'name' => 'Organization', 'authorization_level_id' => 10})
    ApplicableScope.find_by_id(11).update_attributes({'name' => 'Organization', 'authorization_level_id' => 11})
    ApplicableScope.find_by_id(12).update_attributes({'name' => 'Organization', 'authorization_level_id' => 12})
    ApplicableScope.find_by_id(13).update_attributes({'name' => 'Organization', 'authorization_level_id' => 13})
    ApplicableScope.find_by_id(14).update_attributes({'name' => 'Organization', 'authorization_level_id' => 14})
    ApplicableScope.find_by_id(15).update_attributes({'name' => 'Organization', 'authorization_level_id' => 15})
    ApplicableScope.find_by_id(16).update_attributes({'name' => 'Organization', 'authorization_level_id' => 16})
    ApplicableScope.find_by_id(17).update_attributes({'name' => 'Organization', 'authorization_level_id' => 17})
    ApplicableScope.find_by_id(18).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 18})
    ApplicableScope.find_by_id(19).update_attributes({'name' => 'Organization', 'authorization_level_id' => 19})
    ApplicableScope.find_by_id(20).update_attributes({'name' => 'Organization', 'authorization_level_id' => 20})
    ApplicableScope.find_by_id(21).update_attributes({'name' => 'Organization', 'authorization_level_id' => 21})
    ApplicableScope.find_by_id(22).update_attributes({'name' => 'Organization', 'authorization_level_id' => 22})
    ApplicableScope.find_by_id(23).update_attributes({'name' => 'Organization', 'authorization_level_id' => 23})
    ApplicableScope.find_by_id(24).update_attributes({'name' => 'Organization', 'authorization_level_id' => 24})
    ApplicableScope.find_by_id(25).update_attributes({'name' => 'Organization', 'authorization_level_id' => 25})
    ApplicableScope.find_by_id(26).update_attributes({'name' => 'Organization', 'authorization_level_id' => 26})
    ApplicableScope.find_by_id(27).update_attributes({'name' => 'Organization', 'authorization_level_id' => 27})
    ApplicableScope.find_by_id(28).update_attributes({'name' => 'Organization', 'authorization_level_id' => 28})
    ApplicableScope.find_by_id(29).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 29})
    ApplicableScope.find_by_id(30).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 30})
    ApplicableScope.find_by_id(31).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 31})
    ApplicableScope.find_by_id(32).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 32})
    ApplicableScope.find_by_id(33).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 33})
    ApplicableScope.find_by_id(34).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 34})
    ApplicableScope.find_by_id(35).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 35})
    ApplicableScope.find_by_id(36).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 36})
  end

