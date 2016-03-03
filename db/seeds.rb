# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

  reset_authorization_table = true
  reset_applicable_scopes_table = true

  old_authorization_levels = false
  new_authorization_levels = true
  new_applicable_scopes = true

  if reset_authorization_table then AuthorizationLevel.destroy_all end

  if old_authorization_levels
    AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 1,
                               'old_level_id'=> 1,
                              'description' => 'Core System Administrator',
                              'explanation' => 'All access, everywhere,  all the time.'})
    AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 1,
                               'old_level_id'=> 2,
                               'description' => 'Organization System Administrator',
                               'explanation' => 'User can perform all system adminstration functions for the organization.'})
    AuthorizationLevel.create({'name' => 'friend', 'coop_app_id' => 1,
                               'old_level_id'=> 3,
                               'description' => 'Friend of Affiliate',
                               'explanation' => 'This identifies the users who have an affiliation with the organization. Each user either tagged the organization or identified the organization when registering.'})
    AuthorizationLevel.create({'name' => 'content_manager', 'coop_app_id' => 1,
                               'old_level_id'=> 4,
                               'description' => 'Resource Library Contributor',
                               'explanation' => 'This allows the user to add resources to the commont resource library.'})
    AuthorizationLevel.create({'name' => 'classroom_manager', 'coop_app_id' => 2,
                               'old_level_id'=> 5,
                               'description' => 'Classroom Administrator',
                               'explanation' => "This allows the user to manage all of the organization's class offerings as though the user were a teacher for them all.
                                It also allows the user to create new offerings, define the section/periods for each offering, and assign teachers to each section/period."})
    AuthorizationLevel.create({'name' => 'leader', 'coop_app_id' => 2,
                               'old_level_id'=> 6,
                               'description' => 'Teacher',
                               'explanation' => 'This designates the user as a teacher for a particular class offering.'})
    AuthorizationLevel.create({'name' => 'participant', 'coop_app_id' => 1,
                               'old_level_id'=> 7,
                               'description' => 'Student',
                               'explanation' => 'This designates the user as a student for a particular class offering.'})
    AuthorizationLevel.create({'name' => 'favorite', 'coop_app_id' => 1,
                               'old_level_id'=> 8,
                               'description' => 'Favorite Scope ID',
                               'explanation' => 'This tags an entity, such as a class offering, or library resource, as a favorite of a user.'})
    AuthorizationLevel.create({'name' => 'colleague', 'coop_app_id' => 1,
                               'old_level_id'=> 9,
                               'description' => 'Colleague of a User',
                               'explanation' => 'This establishes connections between User to faciliate resource exchanges.'})
    AuthorizationLevel.create({'name' => 'beta_user', 'coop_app_id' => 1,
                               'old_level_id'=> 10,
                               'description' => 'Beta Project Participant',
                               'explanation' => "This desginates the user as a beta project participant, giving the user access to features related to a
                                particular project and not available to users not involved with the project."})
    AuthorizationLevel.create({'name' => 'ifa_administrator', 'coop_app_id' => 3,
                               'old_level_id'=> 11,
                               'description' => "Integrated Formative Assessment Administrator",
                               'explanation' => "This gives the user administrative authority for the Integrated Formative Assessment (IFA) application.
                               User can adjust IFA configuration options, manage assessment repositories, and view IFA dashboards."})
    AuthorizationLevel.create({'name' => 'ita_administrator', 'coop_app_id' => 4,
                               'old_level_id'=> 12,
                               'description' => 'Integrated Teacher Assessment Admin',
                               'explanation' => "This gives the user administrative authority for the Integrated Teacher Assessment (ITA) application.
                               User can specify teacher metrics to be gathered for the organization."})
    AuthorizationLevel.create({'name' => 'blog_panelist', 'coop_app_id' => 5,
                               'old_level_id'=> 13,
                               'description' => 'Blogger For The Organization',
                               'explanation' => 'This identifies the user as a blog panalist. User will be able to post to blogs discussions for which he is identified as a panelist.'})
    AuthorizationLevel.create({'name' => 'ctl_observer', 'coop_app_id' => 6,
                               'old_level_id'=> 14,
                               'description' => 'Time & Learning Observer',
                               'explanation' => "This designates the user as a classroom observer. User will be able to conduct Time & Learning observations for any of the organization's class offerings."})
    AuthorizationLevel.create({'name' => 'ctl_administrator', 'coop_app_id' => 6,
                               'old_level_id'=> 15,
                               'description' => 'Time & Learning Administrator',
                               'explanation' => "This gives the user administrative authority for the Collaborative Time & Learning (CTL) application.
                                User can specify CTL configuration options, create/issue Surveys, and view all CTL dashboards."})
    AuthorizationLevel.create({'name' => 'teacher', 'coop_app_id' => 1,
                               'old_level_id'=> 16,
                               'description' => 'Org Teacher',
                               'explanation' => "This identifies the user as a teacher who can be assigned a section/period for any of the organization's class offerings."})
    AuthorizationLevel.create({'name' => 'pd_administrator', 'coop_app_id' => 7,
                               'old_level_id'=> 17,
                               'description' => 'Professional Development Administrator',
                               'explanation' => "This gives the user administrative authority for the Discover Action & Learning Process (DALP) professional development methodology.
                               User can specify DALP configuration options, create/issue surveys, and view all DALP dashboards."})
    AuthorizationLevel.create({'name' => 'app_superuser', 'coop_app_id' => 1,
                               'old_level_id'=> 18,
                               'description' => 'Core System Administrator For Application',
                               'explanation' => 'This gives the user rights to perform universal maintenance functions for the Application.'})
    AuthorizationLevel.create({'name' => 'stat_administrator', 'coop_app_id' => 8,
                               'old_level_id'=> 19,
                               'description' => 'School Time Analysis Administrator',
                               'explanation' => 'This gives the user administrative authority for the Integrated School Time Analysis application.'})
    AuthorizationLevel.create({'name' => 'stat_user', 'coop_app_id' => 8,
                               'old_level_id'=> 20,
                               'description' => 'School Time Analysis User',
                               'explanation' => 'This gives the user authority use the Integrated School Time Analysis application.'})
    AuthorizationLevel.create({'name' => 'cm_administrator', 'coop_app_id' => 9,
                               'old_level_id'=> 21,
                               'description' => 'Client Management Administrator',
                               'explanation' => 'This gives the user Administrator authority for the Client Management application.'})
    AuthorizationLevel.create({'name' => 'cm_client_manager', 'coop_app_id' => 9,
                               'old_level_id'=> 22,
                               'description' => 'Knowledge Manager',
                               'explanation' => 'This gives the user Knowledge Manager authority for the Client Management application.'})
    AuthorizationLevel.create({'name' => 'cm_consultant', 'coop_app_id' => 9,
                               'old_level_id'=> 23,
                               'description' => 'Consultant',
                               'explanation' => 'This gives the user Consultant authority for the Client Management application.'})
    AuthorizationLevel.create({'name' => 'elt_administrator', 'coop_app_id' => 10,
                               'old_level_id'=> 24,
                               'description' => 'ELT Administrator',
                               'explanation' => 'This gives the user Administrator authority for the ELT application.'})
    AuthorizationLevel.create({'name' => 'elt_team_member', 'coop_app_id' => 10,
                               'old_level_id'=> 25,
                               'description' => 'ELT Team Member',
                               'explanation' => 'This makes the user a Team Member for ELT workshops.'})
    AuthorizationLevel.create({'name' => 'content_administrator', 'coop_app_id' => 1,
                               'old_level_id'=> 26,
                               'description' => 'Resource Library Administrator',
                               'explanation' => 'This allows the user to manage all library resources for the organization.'})
    AuthorizationLevel.create({'name' => 'elt_reviewer', 'coop_app_id' => 10,
                               'old_level_id'=> 27,
                               'description' => 'ELT Case Reviewer',
                               'explanation' => 'This allows the user to reiew and finalize all performance monitoring diagnostic cases.'})
    AuthorizationLevel.create({'name' => 'blog_administrator', 'coop_app_id' => 5,
                               'old_level_id'=> 28,
                               'description' => 'A Blog Administrator For The Organization',
                               'explanation' => "This identifies the user as a blog administrator. User will be able to create and maintain the organization's blogs."})
    AuthorizationLevel.create({'name' => 'stub', 'coop_app_id' => 1,
                               'old_level_id'=> 100,
                               'description' => 'stub so next authorization level starts at 101',
                               'explanation' => 'stub'})
  end

  if new_authorization_levels
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 1,
                                'old_level_id'=> 1,
                                'description' => 'Core System Administrator',
                                'explanation' => 'All access, everywhere,  all the time.'})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 1,
                                'old_level_id'=> 2,
                                'description' => 'Organization System Administrator',
                                'explanation' => 'User can perform all system adminstration functions for the organization.'})
     AuthorizationLevel.create({'name' => 'friend', 'coop_app_id' => 1,
                                'old_level_id'=> 3,
                                'description' => 'Friend of an Affiliate',
                                'explanation' => "This identifies the users who have an affiliation with the organization.
                                Each user either tagged the organization or identified the organization when registering."})
     AuthorizationLevel.create({'name' => 'knowledge_manager', 'coop_app_id' => 1,
                                'old_level_id'=> 4,
                                'description' => 'Resource Library Contributor',
                                'explanation' => "This allows the user to add resources to the commont resource library."})
     AuthorizationLevel.create({'name' => 'library_administrator', 'coop_app_id' => 1,
                                'old_level_id'=> 26,
                                'description' => "Resource Library Administrator",
                                'explanation' => "This allows the user to manage all library resources for the organization."})
     AuthorizationLevel.create({'name' => 'favorite', 'coop_app_id' => 1,
                                'old_level_id'=> 8,
                                'description' => "Favorite Scope ID",
                                'explanation' => "This tags an entity, such as a class offering, or library resource, as a favorite of a user."})
     AuthorizationLevel.create({'name' => 'colleague', 'coop_app_id' => 1,
                                'old_level_id'=> 9,
                                'description' => "Colleague of a User",
                                'explanation' => "This establishes connections between User to faciliate resource exchanges."})
     AuthorizationLevel.create({'name' => 'teacher', 'coop_app_id' => 1,
                                'old_level_id'=> 16,
                                'description' => "Org Teacher",
                                'explanation' => "This identifies the user as a teacher who can be assigned a section/period
                                for any of the organization's class offerings."})
     AuthorizationLevel.create({'name' => 'beta_user', 'coop_app_id' => 1,
                                'old_level_id'=> 10,
                                'description' => "Beta Project Participant",
                                'explanation' => "This desginates the user as a beta project participant, giving the user access to features related to a
                                particular project and not available to users not involved with the project."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 2,
                                'old_level_id'=> 5,
                                'description' => "Offering Administrator",
                                'explanation' => "This allows the user to manage all of the organization's class offerings as though the user were a teacher for them all.
                                It also allows the user to create new offerings, define the section/periods for each offering, and assign teachers to each section/period."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 2,
                                'old_level_id'=> 30,
                                'description' => "Offering Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'teacher', 'coop_app_id' => 2,
                                'old_level_id'=> 6,
                                'description' => "Teacher",
                                'explanation' => "This designates the user as a teacher for a particular class offering."})
     AuthorizationLevel.create({'name' => 'student', 'coop_app_id' => 2,
                                'old_level_id'=> 7,
                                'description' => "Student",
                                'explanation' => "This designates the user as a student for a particular class offering."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 3,
                                'old_level_id'=> 11,
                                'description' => "Integrated Formative Assessment Administrator",
                                'explanation' => "This gives the user administrative authority for the Integrated Formative Assessment (IFA) application.
                                User can adjust IFA configuration options, manage assessment repositories, and view IFA dashboards."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 3,
                                'old_level_id'=> 31,
                                'description' => "IFA Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 4,
                                'old_level_id'=> 12,
                                'description' => "Integrated Teacher Assessment Administrator",
                                'explanation' => "This gives the user administrative authority for the Integrated Teacher Assessment (ITA) application.
                                User can specify teacher metrics to be gathered for the organization."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 4,
                                'old_level_id'=> 32,
                                'description' => "ITA Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 5,
                                'old_level_id'=> 28,
                                'description' => "Blog Administrator",
                                'explanation' => "This identifies the user as a blog administrator. User will be able to create and maintain the organization's blogs."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 5,
                                'old_level_id'=> 33,
                                'description' => "Blog Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'panelist', 'coop_app_id' => 5,
                                'old_level_id'=> 13,
                                'description' => "Blogger For The Organization",
                                'explanation' => "User is a blog panalist. User will be able to post to blogs discussions for which he is identified as a panelist."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 6,
                                'old_level_id'=> 15,
                                'description' => "Collaborative Time & Learning Administrator",
                                'explanation' => "This gives the user administrative authority for the Collaborative Time & Learning (CTL) application.
                                User can specify CTL configuration options, create/issue Surveys, and view all CTL dashboards."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 6,
                                'old_level_id'=> 18,
                                'description' => "CTL Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'observer', 'coop_app_id' => 6,
                                'old_level_id'=> 14,
                                'description' => "Collaborative Time & Learning Observer",
                                'explanation' => "This designates the user as a classroom observer. User will be able to conduct Time & Learning observations for any of the organization's class offerings."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 7,
                                'old_level_id'=> 17,
                                'description' => "Professional Development Administrator",
                                'explanation' => "This gives the user administrative authority for the Discover Action & Learning Process (DALP) professional development methodology.
                                User can specify DALP configuration options, create/issue surveys, and view all DALP dashboards."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 7,
                                'old_level_id'=> 34,
                                'description' => "PD Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'user', 'coop_app_id' => 8,
                                'old_level_id'=> 20,
                                'description' => "School Time Analysis User",
                                'explanation' => "This gives the user authority use the Integrated School Time Analysis application."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 8,
                                'old_level_id'=> 19,
                                'description' => "School Time Analysis Admin",
                                'explanation' => "This gives the user administrative authority for the Integrated School Time Analysis application."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 8,
                                'old_level_id'=> 35,
                                'description' => "STAT Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 9,
                                'old_level_id'=> 21,
                                'description' => "Client Management Administrator",
                                'explanation' => "This gives the user Administrator authority for the Client Management application."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 9,
                                'old_level_id'=> 36,
                                'description' => "CM Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'knowledge_manager', 'coop_app_id' => 9,
                                'old_level_id'=> 22,
                                'description' => "Knowledge Manager",
                                'explanation' => "This gives the user Knowledge Manager authority for the Client Management application."})
     AuthorizationLevel.create({'name' => 'consultant', 'coop_app_id' => 9,
                                'old_level_id'=> 23,
                                'description' => "Consultant",
                                'explanation' => "This gives the user Consultant authority for the Client Management application."})
     AuthorizationLevel.create({'name' => 'administrator', 'coop_app_id' => 10,
                                'old_level_id'=> 24,
                                'description' => "ELT Administrator",
                                'explanation' => "This gives the user Administrator authority for the ELT application."})
     AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 10,
                                'old_level_id'=> 37,
                                'description' => "ELT Application Superuser",
                                'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
     AuthorizationLevel.create({'name' => 'user', 'coop_app_id' => 10,
                                'old_level_id'=> 25,
                                'description' => "ELT User",
                                'explanation' => "This allows access to the ELT application."})
     AuthorizationLevel.create({'name' => 'reviewer', 'coop_app_id' => 10,
                                'old_level_id'=> 27,
                                'description' => "ELT Case Reviewer",
                                'explanation' => "This allows the user to reiew and finalize all performance monitoring diagnostic cases."})
  end

  if reset_applicable_scopes_table then ApplicableScope.destroy_all end
  if new_applicable_scopes
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 1})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 2})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 3})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 4})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 5})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 6})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 7})
    ApplicableScope.create({'name' => 'Content', 'old_level_id'=> 8})
    ApplicableScope.create({'name' => 'Classroom', 'old_level_id'=> 8})
    ApplicableScope.create({'name' => 'User', 'old_level_id'=> 9})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 10})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 11})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 12})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 13})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 14})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 15})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 16})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 17})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 18})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 19})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 20})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 21})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 22})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 23})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 24})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 25})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 26})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 27})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 28})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 30})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 31})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 32})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 33})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 34})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 35})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 36})
    ApplicableScope.create({'name' => 'Organization', 'old_level_id'=> 37})
  end

