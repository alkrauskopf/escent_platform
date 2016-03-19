# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

  add_authorization_levels = false
  update_authorization_levels = true

  add_applicable_scopes = false
  update_applicable_scopes = true

  if add_authorization_levels

  end

  if add_applicable_scopes

  end

  if update_authorization_levels
    AuthorizationLevel.find_by_id(1).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 1,
                                'old_level_id'=> 1,
                                'description' => 'Core System Administrator',
                                'explanation' => 'All access, everywhere,  all the time.'})

    AuthorizationLevel.find_by_id(2).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 1,
                                'old_level_id'=> 2,
                                'description' => 'Organization System Administrator',
                                'explanation' => 'User can perform all system adminstration functions for the organization.'})

    AuthorizationLevel.find_by_id(3).update_attributes({
                                'name' => 'friend', 'coop_app_id' => 1,
                                'old_level_id'=> 3,
                                'description' => 'Friend of an Affiliate',
                                'explanation' => "This identifies the users who have an affiliation with the organization.
                                Each user either tagged the organization or identified the organization when registering."})

    AuthorizationLevel.find_by_id(4).update_attributes({
                                'name' => 'knowledge_manager', 'coop_app_id' => 1,
                                'old_level_id'=> 4,
                                'description' => 'Resource Library Contributor',
                                'explanation' => "This allows the user to add resources to the commont resource library."})

    AuthorizationLevel.find_by_id(5).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 2,
                                'old_level_id'=> 5,
                                'description' => "Offering Administrator",
                                'explanation' => "This allows the user to manage all of the organization's class offerings as though the user were a teacher for them all.
                                It also allows the user to create new offerings, define the section/periods for each offering, and assign teachers to each section/period."})

    AuthorizationLevel.find_by_id(6).update_attributes({
                                'name' => 'teacher', 'coop_app_id' => 2,
                                'old_level_id'=> 6,
                                'description' => "Teacher",
                                'explanation' => "This designates the user as a teacher for a particular class offering."})

    AuthorizationLevel.find_by_id(7).update_attributes({
                                'name' => 'student', 'coop_app_id' => 2,
                                'old_level_id'=> 7,
                                'description' => "Student",
                                'explanation' => "This designates the user as a student for a particular class offering."})

    AuthorizationLevel.find_by_id(8).update_attributes({
                                 'name' => 'favorite', 'coop_app_id' => 1,
                                 'old_level_id'=> 8,
                                 'description' => "Favorite Scope ID",
                                 'explanation' => "This tags an entity, such as a class offering, or library resource, as a favorite of a user."})

    AuthorizationLevel.find_by_id(9).update_attributes({
                                 'name' => 'colleague', 'coop_app_id' => 1,
                                 'old_level_id'=> 9,
                                 'description' => "Colleague of a User",
                                 'explanation' => "This establishes connections between User to faciliate resource exchanges."})

    AuthorizationLevel.find_by_id(10).update_attributes({
                                 'name' => 'beta_user', 'coop_app_id' => 1,
                                 'old_level_id'=> 10,
                                 'description' => "Beta Project Participant",
                                 'explanation' => "This desginates the user as a beta project participant, giving the user access to features related to a
                                 particular project and not available to users not involved with the project."})

    AuthorizationLevel.find_by_id(11).update_attributes({
                                  'name' => 'administrator', 'coop_app_id' => 3,
                                  'old_level_id'=> 11,
                                  'description' => "Integrated Formative Assessment Administrator",
                                  'explanation' => "This gives the user administrative authority for the Integrated Formative Assessment (IFA) application.
                                  User can adjust IFA configuration options, manage assessment repositories, and view IFA dashboards."})

    AuthorizationLevel.find_by_id(12).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 4,
                                 'old_level_id'=> 12,
                                 'description' => "Integrated Teacher Assessment Administrator",
                                 'explanation' => "This gives the user administrative authority for the Integrated Teacher Assessment (ITA) application.
                                 User can specify teacher metrics to be gathered for the organization."})

    AuthorizationLevel.find_by_id(13).update_attributes({
                                  'name' => 'panelist', 'coop_app_id' => 5,
                                  'old_level_id'=> 13,
                                  'description' => "Blogger For The Organization",
                                  'explanation' => "User is a blog panalist. User will be able to post to blogs discussions for which he is identified as a panelist."})

    AuthorizationLevel.find_by_id(14).update_attributes({
                                  'name' => 'observer', 'coop_app_id' => 6,
                                  'old_level_id'=> 14,
                                  'description' => "Collaborative Time & Learning Observer",
                                  'explanation' => "This designates the user as a classroom observer. User will be able to conduct Time & Learning observations for any of the organization's class offerings."})

    AuthorizationLevel.find_by_id(15).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 6,
                                'old_level_id'=> 15,
                                'description' => "Collaborative Time & Learning Administrator",
                                'explanation' => "This gives the user administrative authority for the Collaborative Time & Learning (CTL) application.
                                User can specify CTL configuration options, create/issue Surveys, and view all CTL dashboards."})

    AuthorizationLevel.find_by_id(16).update_attributes({
                                 'name' => 'teacher', 'coop_app_id' => 1,
                                 'old_level_id'=> 16,
                                 'description' => "Org Teacher",
                                 'explanation' => "This identifies the user as a teacher who can be assigned a section/period
                                 for any of the organization's class offerings."})

    AuthorizationLevel.find_by_id(17).update_attributes({
                                  'name' => 'administrator', 'coop_app_id' => 7,
                                  'old_level_id'=> 17,
                                  'description' => "Professional Development Administrator",
                                  'explanation' => "This gives the user administrative authority for the Discover Action & Learning Process (DALP) professional development methodology.
                                  User can specify DALP configuration options, create/issue surveys, and view all DALP dashboards."})

    AuthorizationLevel.find_by_id(18).update_attributes({
                                  'name' => 'superuser', 'coop_app_id' => 6,
                                  'old_level_id'=> 18,
                                  'description' => "CTL Application Superuser",
                                  'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(19).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 8,
                                'old_level_id'=> 19,
                                'description' => "School Time Analysis Admin",
                                'explanation' => "This gives the user administrative authority for the Integrated School Time Analysis application."})

    AuthorizationLevel.find_by_id(20).update_attributes({
                                'name' => 'user', 'coop_app_id' => 8,
                                'old_level_id'=> 20,
                                'description' => "School Time Analysis User",
                                'explanation' => "This gives the user authority use the Integrated School Time Analysis application."})

    AuthorizationLevel.find_by_id(21).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 9,
                                'old_level_id'=> 21,
                                'description' => "Client Management Administrator",
                                'explanation' => "This gives the user Administrator authority for the Client Management application."})

    AuthorizationLevel.find_by_id(22).update_attributes({
                                'name' => 'knowledge_manager', 'coop_app_id' => 9,
                                'old_level_id'=> 22,
                                'description' => "Knowledge Manager",
                                'explanation' => "This gives the user Knowledge Manager authority for the Client Management application."})

    AuthorizationLevel.find_by_id(23).update_attributes({
                                'name' => 'consultant', 'coop_app_id' => 9,
                                'old_level_id'=> 23,
                                'description' => "Consultant",
                                'explanation' => "This gives the user Consultant authority for the Client Management application."})

    AuthorizationLevel.find_by_id(24).update_attributes({
                                'name' => 'administrator', 'coop_app_id' => 10,
                                'old_level_id'=> 24,
                                'description' => "ELT Administrator",
                                'explanation' => "This gives the user Administrator authority for the ELT application."})

    AuthorizationLevel.find_by_id(25).update_attributes({
                                'name' => 'user', 'coop_app_id' => 10,
                                'old_level_id'=> 25,
                                'description' => "ELT User",
                                'explanation' => "This allows access to the ELT application."})

    AuthorizationLevel.find_by_id(26).update_attributes({
                               'name' => 'library_administrator', 'coop_app_id' => 1,
                               'old_level_id'=> 26,
                               'description' => "Resource Library Administrator",
                               'explanation' => "This allows the user to manage all library resources for the organization."})

    AuthorizationLevel.find_by_id(27).update_attributes({
                              'name' => 'reviewer', 'coop_app_id' => 10,
                              'old_level_id'=> 27,
                              'description' => "ELT Case Reviewer",
                              'explanation' => "This allows the user to reiew and finalize all performance monitoring diagnostic cases."})

    AuthorizationLevel.find_by_id(28).update_attributes({
                              'name' => 'administrator', 'coop_app_id' => 5,
                              'old_level_id'=> 28,
                              'description' => "Blog Administrator",
                              'explanation' => "This identifies the user as a blog administrator. User will be able to create and maintain the organization's blogs."})

    AuthorizationLevel.find_by_id(29).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 7,
                                'old_level_id'=> 29,
                                'description' => "PD Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(30).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 8,
                                'old_level_id'=> 30,
                                'description' => "STAT Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(31).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 9,
                                'old_level_id'=> 31,
                                'description' => "CM Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(32).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 10,
                                'old_level_id'=> 32,
                                'description' => "ELT Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(33).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 2,
                                'old_level_id'=> 33,
                                'description' => "Offering Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(34).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 3,
                                'old_level_id'=> 34,
                                'description' => "IFA Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(35).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 4,
                                'old_level_id'=> 35,
                                'description' => "ITA Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.find_by_id(36).update_attributes({
                                'name' => 'superuser', 'coop_app_id' => 5,
                                'old_level_id'=> 36,
                                'description' => "Blog Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
  end

  if update_applicable_scopes
    ApplicableScope.find_by_id(1).update_attributes({'name' => 'Organization', 'authorization_level_id' => 2, 'old_level_id'=> 1})
    ApplicableScope.find_by_id(2).update_attributes({'name' => 'Organization', 'authorization_level_id' => 3, 'old_level_id'=> 2})
    ApplicableScope.find_by_id(3).update_attributes({'name' => 'Classroom', 'authorization_level_id' => 8, 'old_level_id'=> 3})
    ApplicableScope.find_by_id(4).update_attributes({'name' => 'Organization', 'authorization_level_id' => 4, 'old_level_id'=> 4})
    ApplicableScope.find_by_id(5).update_attributes({'name' => 'Organization', 'authorization_level_id' => 5, 'old_level_id'=> 5})
    ApplicableScope.find_by_id(6).update_attributes({'name' => 'Classroom', 'authorization_level_id' => 6, 'old_level_id'=> 6})
    ApplicableScope.find_by_id(7).update_attributes({'name' => 'Classroom', 'authorization_level_id' => 7, 'old_level_id'=> 7})
    ApplicableScope.find_by_id(8).update_attributes({'name' => 'Content', 'authorization_level_id' => 8, 'old_level_id'=> 8})
    ApplicableScope.find_by_id(9).update_attributes({'name' => 'User', 'authorization_level_id' => 9, 'old_level_id'=> 9})
    ApplicableScope.find_by_id(10).update_attributes({'name' => 'Organization', 'authorization_level_id' => 10, 'old_level_id'=> 10})
    ApplicableScope.find_by_id(11).update_attributes({'name' => 'Organization', 'authorization_level_id' => 11, 'old_level_id'=> 11})
    ApplicableScope.find_by_id(12).update_attributes({'name' => 'Organization', 'authorization_level_id' => 12, 'old_level_id'=> 12})
    ApplicableScope.find_by_id(13).update_attributes({'name' => 'Organization', 'authorization_level_id' => 13, 'old_level_id'=> 13})
    ApplicableScope.find_by_id(14).update_attributes({'name' => 'Organization', 'authorization_level_id' => 14, 'old_level_id'=> 14})
    ApplicableScope.find_by_id(15).update_attributes({'name' => 'Organization', 'authorization_level_id' => 15, 'old_level_id'=> 15})
    ApplicableScope.find_by_id(16).update_attributes({'name' => 'Organization', 'authorization_level_id' => 16, 'old_level_id'=> 16})
    ApplicableScope.find_by_id(17).update_attributes({'name' => 'Organization', 'authorization_level_id' => 17, 'old_level_id'=> 17})
    ApplicableScope.find_by_id(18).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 18, 'old_level_id'=> 18})
    ApplicableScope.find_by_id(19).update_attributes({'name' => 'Organization', 'authorization_level_id' => 19, 'old_level_id'=> 19})
    ApplicableScope.find_by_id(20).update_attributes({'name' => 'Organization', 'authorization_level_id' => 20, 'old_level_id'=> 20})
    ApplicableScope.find_by_id(21).update_attributes({'name' => 'Organization', 'authorization_level_id' => 21, 'old_level_id'=> 21})
    ApplicableScope.find_by_id(22).update_attributes({'name' => 'Organization', 'authorization_level_id' => 22, 'old_level_id'=> 22})
    ApplicableScope.find_by_id(23).update_attributes({'name' => 'Organization', 'authorization_level_id' => 23, 'old_level_id'=> 23})
    ApplicableScope.find_by_id(24).update_attributes({'name' => 'Organization', 'authorization_level_id' => 24, 'old_level_id'=> 24})
    ApplicableScope.find_by_id(25).update_attributes({'name' => 'Organization', 'authorization_level_id' => 25, 'old_level_id'=> 25})
    ApplicableScope.find_by_id(26).update_attributes({'name' => 'Organization', 'authorization_level_id' => 26, 'old_level_id'=> 26})
    ApplicableScope.find_by_id(27).update_attributes({'name' => 'Organization', 'authorization_level_id' => 27, 'old_level_id'=> 27})
    ApplicableScope.find_by_id(28).update_attributes({'name' => 'Organization', 'authorization_level_id' => 28, 'old_level_id'=> 28})
    ApplicableScope.find_by_id(29).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 29, 'old_level_id'=> 29})
    ApplicableScope.find_by_id(30).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 30, 'old_level_id'=> 30})
    ApplicableScope.find_by_id(31).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 31, 'old_level_id'=> 31})
    ApplicableScope.find_by_id(32).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 32, 'old_level_id'=> 32})
    ApplicableScope.find_by_id(33).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 33, 'old_level_id'=> 33})
    ApplicableScope.find_by_id(34).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 34, 'old_level_id'=> 34})
    ApplicableScope.find_by_id(35).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 35, 'old_level_id'=> 35})
    ApplicableScope.find_by_id(36).update_attributes({'name' => 'CoopApp', 'authorization_level_id' => 36, 'old_level_id'=> 36})
  end

