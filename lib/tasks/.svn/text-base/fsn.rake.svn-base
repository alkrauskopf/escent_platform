namespace :fsn do
  desc "set up the fsn data initially"
  task :setup => :environment do
    Organization.destroy(1) rescue nil
    default_organization = Organization.new(:organization_type => OrganizationType.find_by_name("Affiliate"),
      :denomination => Denomination.find_by_name("Non-denominational"),
      :status => Status.find_by_name("Approved"),
      :name => "Odyssey Networks, LLC.",
      :web_site_url => "http://www.odysseynetworks.org/",
      :phone => "212.870.1030",
      :fax => "212.870.1040")
    default_organization.id = 1
    default_organization.save
    User.destroy(1) rescue nil
    superuser = User.new(:id => 1, :email_address => "administrator", :first_name => "superuser", :display_name => "superuser", :read_tos => true, :age_verified => true)
    superuser.id = 1
    superuser.save
  end
  
  desc "migrate topics and discussions into their own tables"
  task :migrate_topics => :environment do
    Topic.delete_all
    Discussion.delete_all
    Channel.find(:all, :conditions => ["type = ? OR type = ?", "Topic", "Discussion"]).each do |channel|
      puts "#{channel.type} #{channel.id}: #{channel.title}"
      if channel[:type] == "Topic"
        discussion = Channel.find_by_parent_id(channel.id)
        topic = Topic.new(
          :user_id => channel.user_id,
          :organization_id => channel.organization_id,
          :title => channel.title, 
          :description => "#{discussion.title}<br />#{discussion.description}",
          :publish_starts_at => channel.publish_start_date,
          :publish_ends_at => channel.publish_end_date,
          :created_at => channel.created_at,
          :updated_at => channel.updated_at,
          :last_posted_at => channel.last_posted_at
        )
        topic.id = channel.id
        topic.save(false)
        ChannelContent.find(:all, :conditions => ["channel_id = ?", channel.id]).each do |channel_content|
          topic.topic_contents.create(
            :content_id => channel_content.content_id,
            :position => channel_content.position,
            :created_at => channel_content.created_at,
            :updated_at => channel_content.updated_at
          )
        end
        #puts "error for #{topic.id} #{topic.errors.full_messages.to_sentence}"
      else
        if channel.parent_id
          topic = find_topic_of(channel)
          parent_channel = Channel.find(channel.parent_id)
          grandparent_channel = parent_channel.parent_id ? Channel.find(parent_channel.parent_id) : nil
          if parent_channel[:type] == "Discussion"
            discussion = Discussion.new(
              :user_id => channel.user_id,
              :parent_id => grandparent_channel == topic ? nil : channel.parent_id,
              :topic_id => topic.id,
              :organization_id => channel.organization_id,
              :comment => channel.description,
              :created_at => channel.created_at,
              :updated_at => channel.updated_at
            )
            discussion.id = channel.id
            discussion.save(false)
          end
        end
      end
    end
  end
  
  desc "migrate sections into to contain its own data"
  task :migrate_page_sections => :environment do
    PageSection.all.each do |page_section|
      content = Content.find(page_section.content_id) rescue nil
      if content
        page_section.update_attributes! :body => content.content_object
        if ENV['DELETE_CONTENT'] == 'true'
          content.destroy
        end
      end
    end
  end
  
  desc "migrate role information into authorization levels"
  task :migrate_authorization_levels => :environment do
    ENV['MODEL'] = 'AuthorizationLevel,AuthorizableAction'
    Rake::Task['fixtures:reload'].invoke
    Authorization.destroy_all
    Role.all.each do |role|
      if role.builtin?
        puts role.scope.name + ": " + role.name
        role.users.each do |user|
          case role.name
            when "Administrator"
              if role.scope == Organization.default
                user.authorizations.create :scope => role.scope, :authorization_level => AuthorizationLevel.find_by_name("superuser")
              end
              user.authorizations.create :scope => role.scope, :authorization_level => AuthorizationLevel.find_by_name("administrator")
            
            when  "Associates"
              user.authorizations.create :scope => role.scope, :authorization_level => AuthorizationLevel.find_by_name("friend")
            
            when  "Moderator"
              user.authorizations.create :scope => role.scope, :authorization_level => AuthorizationLevel.find_by_name("discussion_moderator")
          end
        end
      end
    end
  end
  
  desc "migrate data into organization_relationships"
  task :migrate_organization_relationships => :environment do
    OrganizationRelationship.destroy_all
    TrustedSource.all.each do |source|
      puts source[:type] + ": " + source.organization.name
      OrganizationRelationship.create :organization_id => source[:organization_id], :relationship_type => source[:type].underscore, :scope_id => source[:source_id], :scope_type => "Organization", :created_at => source[:created_at], :updated_at => source[:updated_at]
    end
  end
  
  desc "migrate discussion_partner to cause_partner"
  task :migrate_discussion_partners => :environment do
    OrganizationRelationship.update_all("relationship_type = 'cause_partner'", "relationship_type = 'discussion_partner'")
  end
  
  def find_topic_of(channel)
    if channel[:type] == "Topic"
      channel
    else
      find_topic_of(Channel.find(channel.parent_id))
    end
  end
end