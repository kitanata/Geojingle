"""
This file demonstrates two different styles of tests (one doctest and one
unittest). These will both pass when you run "manage.py test".

Replace these with more appropriate tests for your application.
"""

from django.test import TestCase
from django.test.client import Client

class TestOrgTypeList(TestCase):
    fixtures = ['gisedu_org_type', 'gisedu_org']

    def test_org_type_list(self):
        c = Client()

        response = c.get('/org_type_list/')

        self.assertEqual(response.status_code, 200)
    
        self.assertEqual(response.content, '\n["Library", "Media Center", "Other", "School"]\n')

    def test_org_list_by_type(self):

        c = Client()

        response = c.get('/org_list_by_typename/Library/')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, '\n[{"Anthony Wayne": 10751}, {"College Corner": 1}]\n')

class TestOrgInfo(TestCase):
    fixtures = ['gisedu_org', 'gisedu_org_address']

    def test_org_info(self):
        c = Client()

        response = c.get('/edu_org_info/1/')

        expected = '<div id="content">\n    <bold><h3>College Corner</h3></bold>\n    1885 Lake Ave<br />\n    <br />\n    Elyria, OH 44035-2551\n</div>'

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, expected)
        

