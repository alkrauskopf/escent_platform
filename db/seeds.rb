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

  create_a_resource_type = true

  create_a_subject_area = false

  if create_a_resource_type
    if ContentResourceType.where(['name =?', 'Budget']).empty?
      ContentResourceType.create('name' => 'Budget', 'descript' => 'Budget Document')
    end
    if ContentResourceType.where(['name =?', 'Proposal']).empty?
      ContentResourceType.create('name' => 'Proposal', 'descript' => 'Proposal Document')
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

    AuthorizationLevel.create({'name' => 'superuser', 'coop_app_id' => 1,
                              'description' => 'Core System Administrator',
                              'explanation' => 'All access, everywhere,  all the time.'})

    AuthorizationLevel.create({
                             'name' => 'administrator', 'coop_app_id' => 1,
                             'description' => 'Organization System Administrator',
                             'explanation' => 'User can perform all system adminstration functions for the organization.'})

    AuthorizationLevel.create({
                             'name' => 'friend', 'coop_app_id' => 1,
                             'description' => 'Friend of an Affiliate',
                             'explanation' => "This identifies the users who have an affiliation with the organization.
                             Each user either tagged the organization or identified the organization when registering."})

    AuthorizationLevel.create({
                             'name' => 'knowledge_manager', 'coop_app_id' => 1,
                             'description' => 'Resource Library Contributor',
                             'explanation' => "This allows the user to add resources to the commont resource library."})

    AuthorizationLevel.create({
                             'name' => 'administrator', 'coop_app_id' => 2,
                             'description' => "Offering Administrator",
                             'explanation' => "This allows the user to manage all of the organization's class offerings as though the user were a teacher for them all.
                             It also allows the user to create new offerings, define the section/periods for each offering, and assign teachers to each section/period."})

    AuthorizationLevel.create({
                             'name' => 'teacher', 'coop_app_id' => 2,
                             'description' => "Teacher",
                             'explanation' => "This designates the user as a teacher for a particular class offering."})

    AuthorizationLevel.create({
                             'name' => 'student', 'coop_app_id' => 2,
                             'description' => "Student",
                             'explanation' => "This designates the user as a student for a particular class offering."})

    AuthorizationLevel.create({
                             'name' => 'favorite', 'coop_app_id' => 1,
                             'description' => "Favorite Scope ID",
                             'explanation' => "This tags an entity, such as a class offering, or library resource, as a favorite of a user."})

    AuthorizationLevel.create({
                             'name' => 'colleague', 'coop_app_id' => 1,
                             'description' => "Colleague of a User",
                             'explanation' => "This establishes connections between User to faciliate resource exchanges."})

    AuthorizationLevel.create({
                              'name' => 'beta_user', 'coop_app_id' => 1,
                              'description' => "Beta Project Participant",
                              'explanation' => "This desginates the user as a beta project participant, giving the user access to features related to a
                              particular project and not available to users not involved with the project."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 3,
                              'description' => "Integrated Formative Assessment Administrator",
                              'explanation' => "This gives the user administrative authority for the Integrated Formative Assessment (IFA) application.
                              User can adjust IFA configuration options, manage assessment repositories, and view IFA dashboards."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 4,
                              'description' => "Integrated Teacher Assessment Administrator",
                              'explanation' => "This gives the user administrative authority for the Integrated Teacher Assessment (ITA) application.
                              User can specify teacher metrics to be gathered for the organization."})

    AuthorizationLevel.create({
                              'name' => 'panelist', 'coop_app_id' => 5,
                              'description' => "Blogger For The Organization",
                              'explanation' => "User is a blog panalist. User will be able to post to blogs discussions for which he is identified as a panelist."})

    AuthorizationLevel.create({
                              'name' => 'observer', 'coop_app_id' => 6,
                              'description' => "Collaborative Time & Learning Observer",
                              'explanation' => "This designates the user as a classroom observer. User will be able to conduct Time & Learning observations for any of the organization's class offerings."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 6,
                              'description' => "Collaborative Time & Learning Administrator",
                              'explanation' => "This gives the user administrative authority for the Collaborative Time & Learning (CTL) application.
                              User can specify CTL configuration options, create/issue Surveys, and view all CTL dashboards."})

    AuthorizationLevel.create({
                              'name' => 'teacher', 'coop_app_id' => 1,

                              'description' => "Org Teacher",
                              'explanation' => "This identifies the user as a teacher who can be assigned a section/period
                              for any of the organization's class offerings."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 7,
                              'description' => "Professional Development Administrator",
                              'explanation' => "This gives the user administrative authority for the Discover Action & Learning Process (DALP) professional development methodology.
                              User can specify DALP configuration options, create/issue surveys, and view all DALP dashboards."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 6,
                              'description' => "CTL Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 8,
                              'description' => "School Time Analysis Admin",
                              'explanation' => "This gives the user administrative authority for the Integrated School Time Analysis application."})

    AuthorizationLevel.create({
                              'name' => 'user', 'coop_app_id' => 8,
                              'description' => "School Time Analysis User",
                              'explanation' => "This gives the user authority use the Integrated School Time Analysis application."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 9,
                              'description' => "Client Management Administrator",
                              'explanation' => "This gives the user Administrator authority for the Client Management application."})

    AuthorizationLevel.create({
                              'name' => 'knowledge_manager', 'coop_app_id' => 9,
                              'description' => "Knowledge Manager",
                              'explanation' => "This gives the user Knowledge Manager authority for the Client Management application."})

    AuthorizationLevel.create({
                              'name' => 'consultant', 'coop_app_id' => 9,
                              'description' => "Consultant",
                              'explanation' => "This gives the user Consultant authority for the Client Management application."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 10,
                              'description' => "ELT Administrator",
                              'explanation' => "This gives the user Administrator authority for the ELT application."})

    AuthorizationLevel.create({
                              'name' => 'user', 'coop_app_id' => 10,
                              'description' => "ELT User",
                              'explanation' => "This allows access to the ELT application."})

    AuthorizationLevel.create({
                              'name' => 'library_administrator', 'coop_app_id' => 1,
                              'description' => "Resource Library Administrator",
                              'explanation' => "This allows the user to manage all library resources for the organization."})

    AuthorizationLevel.create({
                              'name' => 'reviewer', 'coop_app_id' => 10,
                              'description' => "ELT Case Reviewer",
                              'explanation' => "This allows the user to reiew and finalize all performance monitoring diagnostic cases."})

    AuthorizationLevel.create({
                              'name' => 'administrator', 'coop_app_id' => 5,
                              'description' => "Blog Administrator",
                              'explanation' => "This identifies the user as a blog administrator. User will be able to create and maintain the organization's blogs."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 7,
                              'description' => "PD Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 8,
                              'description' => "STAT Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 9,
                              'description' => "CM Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 10,
                              'description' => "ELT Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 2,
                              'description' => "Offering Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 3,
                              'description' => "IFA Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 4,
                              'description' => "ITA Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})

    AuthorizationLevel.create({
                              'name' => 'superuser', 'coop_app_id' => 5,
                              'description' => "Blog Application Superuser",
                              'explanation' => "This gives the user rights to perform universal maintenance functions for the Application."})
  end

  if create_applicable_scopes
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 2})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 3})
    ApplicableScope.create({'name' => 'Classroom', 'authorization_level_id' => 8})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 4})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 5})
    ApplicableScope.create({'name' => 'Classroom', 'authorization_level_id' => 6})
    ApplicableScope.create({'name' => 'Classroom', 'authorization_level_id' => 7})
    ApplicableScope.create({'name' => 'Content', 'authorization_level_id' => 8})
    ApplicableScope.create({'name' => 'User', 'authorization_level_id' => 9})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 10})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 11})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 12})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 13})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 14})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 15})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 16})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 17})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 18})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 19})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 20})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 21})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 22})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 23})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 24})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 25})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 26})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 27})
    ApplicableScope.create({'name' => 'Organization', 'authorization_level_id' => 28})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 29})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 30})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 31})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 32})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 33})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 34})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 35})
    ApplicableScope.create({'name' => 'CoopApp', 'authorization_level_id' => 36})
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

