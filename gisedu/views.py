# Create your views here.
from django.contrib.gis.geos.collections import GeometryCollection
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json

from string import Template

from models import OhioCounties, OhioSchoolDistricts, OhioEduOrgs

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def json_test(request):

    counties = OhioCounties.objects.all()

    #county = OhioCounties.objects.get(gid=1)

    county_geom = [county.the_geom for county in counties]

    collection = GeometryCollection(county_geom)

    return render_to_response('json/base.json', {'json': collection.json}, context_instance=RequestContext(request))
    #return render_to_response('json/base.json', {'json': county.the_geom.json}, context_instance=RequestContext(request))

def county_list(request):

    counties = OhioCounties.objects.all()

    counties = map(lambda county: {str(county.name) : int(county.gid)}, counties)

    county_list = json.dumps(counties)

    return render_to_response('json/base.json', {'json': county_list}, context_instance=RequestContext(request))



def school_district_list(request):

    districts = OhioSchoolDistricts.objects.all()

    districts = map(lambda district: {str(district.name) : int(district.gid)}, districts)

    district_list = json.dumps(districts)

    return render_to_response('json/base.json', {'json' : district_list}, context_instance=RequestContext(request))



def edu_org_list(request):

    orgs = OhioEduOrgs.objects.all()

    orgs = map(lambda org: {str(org.org_nm) : int(org.gid)}, orgs)

    org_list = json.dumps(orgs)

    return render_to_response('json/base.json', {'json' : org_list}, context_instance=RequestContext(request))



def county(request, county_id):

    county = OhioCounties.objects.get(pk=county_id)

    response = json.dumps({'name' : str(county.name), 'gid' : int(county.gid), 'the_geom' : json.loads(county.the_geom.json)})

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))



def school_district(request, district_id):

    district = OhioSchoolDistricts.objects.get(pk=district_id)

    response = json.dumps({'name' : str(district.name), 'gid' : int(district.gid), 'the_geom' : json.loads(district.the_geom.json)})

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))



def edu_org(request, org_id):

    org = OhioEduOrgs.objects.get(pk=org_id)

    response = json.dumps({'name' : str(org.org_nm), 'gid' : int(org.gid), 'the_geom' : json.loads(org.the_geom.json)})

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))