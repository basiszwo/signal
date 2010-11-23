Feature: Manage projects
  
  Scenario: Register new project
    Given I am on the new projects page
    Then I should not see /Building/
    When I fill in "project_name" with "Geni"
    And I fill in "project_url" with "git://fake"
    And I fill in "project_email" with "fake@too.com"
    And I fill in "project_ruby_version" with "ruby-1.8.7"
    And I fill in "project_rvm_gemset_name" with "geni"
    And I press "Create Project"
    Then a project should exist
    And I should see /Geni/

  
  Scenario: Update a project
    Given a project exists
    And I am on the project's edit page
    Then I should not see /Building/
    When I fill in "project_name" with "Bluepump"
    When I fill in "project_url" with "gitFake"
    And I press "Update Project"
    Then I should see /Bluepump/
    And I should see /gitFake/

  @focus
  Scenario: Remove a project
    Given a project exists with name: "Project X"
    And I am on the project's page
    When I follow "remove"
    Then I should be on the projects page
    # And I should see "Project was deleted."
    And I should not see "Project X"

  Scenario: Build project
    pending # POST link
    # Given a project exists
    # And I am on the project's page
    # When I follow "build"
    # Then a new build should be created
    # And I should see the author of the build
    # And I should see the name of the project

  Scenario: Deploy Project
    pending # POST link
    # Given a project exists
    # And I am on the project's page
    # When I follow "deploy"
    # Then a new deploy should be created
    # And I should see the output of the deploy
    # And I should see the name of the project
    
  Scenario: Get projects status in XML format
    When I am on "/projects/status.xml"
    Then I should get a XML document

  Scenario: RSS
    Given a project exists with name: "Project X"
    When I am on "/"
    Then I should receive a link for the feed of all projects
    And I should receive a link for the feed of the project
    When I am on "/projects.rss"
    Then I should see the name of the project
    When I am on the project's rss page
    Then I should see "Project X"

  Scenario Outline: find project by id
    Given a project exists with name: "<name>"
    When I am on the project's page
    Then I should be on the project's page
    
    Examples:
      | name       |
      | Test       |
      | My Project |


