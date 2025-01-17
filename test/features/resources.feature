@resources
Feature: Resource UI

    Scenario Outline: Link resource should create a link to its URL
        Given "SysAdmin" as the persona
        When I log in
        And I open the new resource form for dataset "test-dataset"
        And I create a resource with key-value parameters "name=<name>::url=<url>"
        And I press the element with xpath "//a[contains(@title, '<name>') and contains(string(), '<name>')]"
        Then I should see "<url>"

        Examples:
        | name | url |
        | Good link | http://www.qld.gov.au |
        | Good IP address | http://1.2.3.4 |
        | Domain starting with numbers | http://1.2.3.4.example.com |
        # chrome url type input treats it as invalid one
        # | Domain ending with numbers | http://example.com.1.2.3.4 |
        | Domain ending with private | http://example.com.private |

    Scenario Outline: Add new resource metadata field on the create and edit resource GUI pages
        Given "<Persona>" as the persona
        When I log in
        And I open the new resource form for dataset "data_request_dataset"
        Then I should see an element with xpath "//label[@for="field-request_privacy_assessment"]"
        And field "request_privacy_assessment" should not be required
        And I should not see an element with xpath "//label[@for="field-request_privacy_assessment"]//*[@class="control-required"]"
        And I should see an element with xpath "//select[@id="field-request_privacy_assessment"]//option[@value="" or @value="YES" or @value="NO"]"
        And I should see "Where the dataset contains de-identified data, selecting ‘YES’ will hide this resource, pending a privacy assessment. Assessments will not be completed where the dataset does not contain de-identified data. Select ‘NO’ where the dataset does not contain de-identified data or where a privacy assessment is not required."
        Examples: roles
        | Persona              |
        | DataRequestOrgAdmin  |
        | DataRequestOrgEditor |
