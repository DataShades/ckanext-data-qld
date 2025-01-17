@dataset_schema
Feature: Resource align_default_schema field

    Scenario: Create or edit resource in the GUI where default_data_schema is NULL, initial display and behaviour
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=package-without-default-schema::schema_json" and "upload=default::format=CSV"
        And I go to dataset "package-without-default-schema"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following-sibling::td[contains(text(),"Field name 'default_data_schema' not in data")]"

        When I go to the first resource in the dataset
        And I press the element with xpath "//a[contains(text(),'Manage')]"
        Then I should not see "Align this data schema with the dataset default"
        And I should see "Upload"
        And I should see "Link"
        And I should see "JSON"

        When I open the new resource form for dataset "package-without-default-schema"
        Then I should not see "Align this data schema with the dataset default"
        And I should see "Upload"
        And I should see "Link"
        And I should see "JSON"


    Scenario: Create resource with schema not aligned to default schema
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "name=package-with-default-schema::schema_json=default"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[contains(text(),"View Schema File")]"

        When I open the new resource form for dataset "package-with-default-schema"
        Then I should see an element with xpath "//div[contains(@class,'schema-align')]/following-sibling::div[@class='image-upload']"
        And I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and @checked]/following-sibling::label[@for='field-align_default_schema' and text()=contains(.,'Align this data schema with the dataset default')]"
        And I should see an element with xpath "//div[@class="info-block " and text()=contains(.,"This data schema value is not aligned with a default data schema. Aligning this resource’s data schema with the dataset’s default data schema (and overwriting any pre-existing schema) ensures consistent validation of data structure.")]"
        And I should see an element with xpath "//div[@class="info-block " and text()=contains(.,"Alternatively, publishers can choose no alignment and may include a customised schema for this resource. Ticking this box and updating the resource will align the schemas, overwriting any existing data schema. The validation options, if any, will not be overwritten.")]"
        And field "align_default_schema" should not be required

        When I create a resource with key-value parameters "align_default_schema=False::upload=csv_resource.csv::format=CSV"
        And I go to the first resource in the dataset
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='FALSE']"

    Scenario: Edit a resource in the GUI where default schema exists and the existing schema value does not match the default
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "schema_json=default" and "name=another-resource::schema=default::align_default_schema=False"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[contains(text(),"View Schema File")]"

        When I go to the first resource in the dataset
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='FALSE']"
        When I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(text(), '"Resource schema"')]"

        When I go back
        And I press the element with xpath "//a[contains(text(),'Manage')]"
        Then I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and not(@checked)]/following-sibling::label[@for='field-align_default_schema' and text()=contains(.,'Align this data schema with the dataset default')]"

        When I check "align_default_schema"
        And I press the element with xpath "//button[text()='Update Resource']"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='TRUE']"
        When I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(text(), '"Default schema"')]"

    Scenario: Edit resource in the GUI where default schema exists and the existing schema value matches the default
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "schema_json=default" and "name=another-resource::schema=::align_default_schema=False"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[contains(text(),"View Schema File")]"

        When I go to the first resource in the dataset
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='FALSE']"
        When I press the element with xpath "//a[contains(text(),'Manage')]"
        Then I should see "Align this data schema with the dataset default"

        When I execute the script "document.getElementById('field-schema').value='{"fields":[{"format": "default","name": "Game Number","type": "integer"},{"format": "default","name": "Game Length","type": "integer"}],"missingValues": ["Default schema"]}'"
        And I press the element with xpath "//button[text()='Update Resource']"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='TRUE']"

        # now default and resource schema are the same
        When I press the element with xpath "//a[contains(text(),'Manage')]"
        Then I should not see "Align this data schema with the dataset default"

        # now default and resource schema are different
        When I press the element with xpath "//textarea[@id='field-schema-json']/preceding-sibling::a[text()='Clear']"
        And I execute the script "document.getElementById('field-schema').value='{"fields":[{"format": "default","name": "Game Number","type": "integer"},{"format": "default","name": "Game Length","type": "integer"}], "missingValues": ["Resource schema"]}'"

        When I press the element with xpath "//button[text()='Update Resource']"
        And I press the element with xpath "//a[contains(text(),'Manage')]"
        Then I should see "Align this data schema with the dataset default"

        When I press the element with xpath "//button[text()='Update Resource']"
        And I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(text(), '"Resource schema"')]"

        When I go back
        And I press the element with xpath "//a[contains(text(),'Manage')]"
        Then I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and not(@checked)]/following-sibling::label[@for='field-align_default_schema' and text()=contains(.,'Align this data schema with the dataset default')]"

        When I check "align_default_schema"
        And I press the element with xpath "//button[text()='Update Resource']"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='TRUE']"

        When I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(text(), '"Default schema"')]"
