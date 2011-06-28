# Create your views here.
from django.contrib.gis.geos.collections import GeometryCollection
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json

from string import Template

from models import OhioCounties, OhioSchoolDistricts, GiseduOrg, GiseduOrgType

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

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



def org_type_list(request):

    types = GiseduOrgType.objects.all()

    types = map(lambda type: str(type.org_type_name), types)

    types.sort()

    type_list = json.dumps(types)

    return render_to_response('json/base.json', {'json' : type_list}, context_instance=RequestContext(request))



def org_list_by_typename(request, type_name):

    orgs = GiseduOrg.objects.filter(org_type__org_type_name=type_name)

    orgs = map(lambda org: {"name": str(org.org_nm), "gid": int(org.gid)}, orgs)

    orgs.sort()

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



def org_geom(request, org_id):

    org = GiseduOrg.objects.get(pk=org_id)

    response = json.dumps({'gid' : int(org.gid), 'the_geom' : json.loads(org.the_geom.json)})

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))



def org_info(request, org_id):

    org = GiseduOrg.objects.get(pk=org_id)

    response = json.dumps({'gid' : int(org.gid), 'name' : org.org_nm, 'type' : org.org_type.org_type_name })

    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))



def org_infobox(request, org_id):

    org = GiseduOrg.objects.get(pk=org_id)

    return render_to_response('edu_org_info.html', {'org_name' : org.org_nm, 'address': org.address}, context_instance=RequestContext(request))

