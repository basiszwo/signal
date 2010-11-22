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
    Then a new project should be created
    And I should see /Geni/

  Scenario: Update a project
    Given I have a project
    And I am on the edit project page
    Then I should not see /Building/
    When I fill in "project_name" with "Bluepump"
    When I fill in "project_url" with "gitFake"
    And I press "Update Project"
    Then I should see /Bluepump/
    And I should see /gitFake/

  Scenario: Remove a project
    Given I have a project with name "Test Project"
    And I am on the project page
    When I follow "remove"
    Then I should be on the projects page
    And I should not see "Test Project"

  Scenario: Build project
    Given I have a project
    And I am on the project page
    When I follow "build"
    Then a new build should be created
    And I should see the author of the build
    And I should see the name of the project

  Scenario: Deploy Project
    Given I have a project
    And I am on the project page
    When I follow "deploy"
    Then a new deploy should be created
    And I should see the output of the deploy
    And I should see the name of the project
    
  Scenario: Get projects status in XML format
    When I request '/projects/status.xml'
    Then I should get a XML document

  Scenario: RSS
    Given I have a project with name "test"
    When I request '/'
    Then I should receive a link for the feed of all projects
    And I should receive a link for the feed of the project
    When I request '/projects.rss' 
    Then I should see the name of the project
    When I request '/projects/test.rss'
    Then I should see the name of the project

  Scenario Outline: find project by id
    Given I have a project with name "<name>"
    When I request '/projects/<slug>'
    Then I should be on "/projects/<slug>"
    
    Examples:
      | name       | slug       |
      | Test       | test       |
      | My Project | my-project |


