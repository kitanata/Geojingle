"""
This file demonstrates two different styles of tests (one doctest and one
unittest). These will both pass when you run "manage.py test".

Replace these with more appropriate tests for your application.
"""

from django.test import TestCase
from django.test.client import Client

class SimpleTest(TestCase):
    def test_basic_addition(self):
        """
        Tests that 1 + 1 always equals 2.
        """
        self.failUnlessEqual(1 + 1, 2)

__test__ = {"doctest": """
Another way to test that 1 + 1 is equal to 2.

>>> 1 + 1 == 2
True
"""}

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
        self.assertEqual(response.content, '\n[{"Anthony Wayne": 10751}, {"College Corner": 11837}]\n')

