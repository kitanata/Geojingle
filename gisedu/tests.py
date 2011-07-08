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
        self.assertEqual(response.content, '\n[{"gid": 1, "name": "College Corner"}, {"gid": 10751, "name": "Anthony Wayne"}]\n')


class TestOrgGeom(TestCase):
    fixtures = ['gisedu_org', 'gisedu_org_type', 'gisedu_org_address']

    def test_org_geom(self):
        c = Client()

        response = c.get('/org_geom/1/')

        expected = '\n{"gid": 1, "the_geom": {"type": "Point", "coordinates": [-84.802600999999996, 39.579509000000002]}}\n'

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, expected)

    def test_org_info(self):
        c = Client()

        response = c.get('/org_info/1/')

        expected = '\n{"gid": 1, "type": "Library", "name": "College Corner"}\n'

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, expected)

    def test_org_infobox(self):
        c = Client()

        response = c.get('/org_infobox/1/')

        expected = '<div id="content">\n    <bold><h3>College Corner</h3></bold>\n    1885 Lake Ave<br />\n    <br />\n    Elyria, OH 44035-2551\n</div>'

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, expected)



class TestFilters(TestCase):
    fixtures = ['gisedu_org', 'gisedu_org_type']
#
#    def test_county_all(self):
#
#        c = Client()
#
#        response = c.get('/filter/county_by_name/All/')
#
#        expected = '\n[]\n'
#
#        self.assertEqual(response.status_code, 200)
#        self.assertEqual(response.content, expected)
#
#    def test_county_athens(self):
#
#        c = Client()
#
#        response = c.get('/filter/county_by_name/Athens/')
#
#        expected = '\n[]\n'
#
#        self.assertEqual(response.status_code, 200)
#        self.assertEqual(response.content, expected)

    def test_org_by_type(self):

        c = Client()

        response = c.get('/filter/org_by_type/Area Media Center/')
        expected = '\n[]\n'

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, expected)

    def test_org_by_name(self):

        c = Client()

        response = c.get('/filter/org_by_name/Eastland Career Center/')
        expected = '\n[]\n'

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, expected)
