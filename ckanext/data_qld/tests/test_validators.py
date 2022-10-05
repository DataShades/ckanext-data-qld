import pytest

import ckan.lib.navl.dictization_functions as df
import ckan.logic.validators as validators
import ckan.model as model
import ckan.tests.factories as factories
import ckan.tests.helpers as helpers
import ckan.tests.lib.navl.test_validators as t

from ckanext.resource_visibility.validators import privacy_assessment_result


def _make_context():
    return {"model": model, "session": model.Session}


@pytest.mark.usefixtures("clean_db", "with_request_context")
class TestPrivacyAssessmentResultValidator:
    '''
    Test that only sysadmin is able to edit a resource
    '''

    def test_non_sysadmins_restricted_to_edit(self, user, dataset_factory,
                                              resource_factory):
        context = _make_context()
        context['user'] = user['name']

        dataset = dataset_factory()
        resource = resource_factory(package_id=dataset["id"],
                                    privacy_assessment_result="initial value")

        value = 'new value'
        key = (u'resources', 0, u'privacy_assessment_result')
        res_id = (u'resources', 0, u'id')

        data = {key: value, res_id: resource["id"]}

        errors = factories.validator_errors_dict()
        errors[key] = []

        with pytest.raises(df.StopOnError):
            privacy_assessment_result(key, data, errors, context)

        assert "You are not allowed to edit this field." in errors[key]

    def test_non_sysadmins_restricted_to_edit_if_value_didnt_change(
            self, user, dataset_factory, resource_factory):
        context = _make_context()
        context['user'] = user['name']

        dataset = dataset_factory()
        resource = resource_factory(package_id=dataset["id"],
                                    privacy_assessment_result="initial value")

        value = 'initial value'
        key = (u'resources', 0, u'privacy_assessment_result')
        res_id = (u'resources', 0, u'id')

        errors = factories.validator_errors_dict()
        errors[key] = []

        data = {key: value, res_id: resource["id"]}

        privacy_assessment_result(key, data, errors, context)

    def test_non_sysadmins_cannot_empty_field(self, user, dataset_factory,
                                              resource_factory):
        context = _make_context()
        context['user'] = user['name']

        dataset = dataset_factory()
        resource = resource_factory(package_id=dataset["id"],
                                    privacy_assessment_result="initial value")

        value = ''
        key = (u'resources', 0, u'privacy_assessment_result')
        res_id = (u'resources', 0, u'id')

        errors = factories.validator_errors_dict()
        errors[key] = []

        data = {key: value, res_id: resource["id"]}

        with pytest.raises(df.StopOnError):
            privacy_assessment_result(key, data, errors, context)

        assert "You are not allowed to edit this field." in errors[key]

    def test_sysadmins_allowed(self, sysadmin, dataset_factory,
                               resource_factory):
        context = _make_context()
        context['user'] = sysadmin['name']

        dataset = dataset_factory()
        resource = resource_factory(package_id=dataset["id"])

        value = 'Data'
        key = (u'resources', 0, u'privacy_assessment_result')
        res_id = (u'resources', 0, u'id')

        data = {key: value, res_id: resource["id"]}

        errors = factories.validator_errors_dict()
        errors[key] = []

        privacy_assessment_result(key, data, errors, context)

    def test_ignore_auth(self, dataset_factory, resource_factory):
        context = _make_context()
        context['ignore_auth'] = True

        dataset = dataset_factory()
        resource = resource_factory(package_id=dataset["id"])

        value = 'Data'
        key = (u'resources', 0, u'privacy_assessment_result')
        res_id = (u'resources', 0, u'id')

        data = {key: value, res_id: resource["id"]}

        errors = factories.validator_errors_dict()
        errors[key] = []

        privacy_assessment_result(key, data, errors, context)
