# Create your views here.
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json
from models import OhioCounties, OhioSchoolDistricts

def browser_test(request):
    return render_to_response('browser_test.html', context_instance=RequestContext(request))

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def google_map(request):
    return render_to_response('map.html', context_instance=RequestContext(request))

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

def county(request, county_id):
    county = OhioCounties.objects.get(pk=county_id)
    response = json.dumps({'name' : str(county.name), 'gid' : int(county.gid), 'the_geom' : json.loads(county.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

def school_district(request, district_id):
    district = OhioSchoolDistricts.objects.get(pk=district_id)
    response = json.dumps({'name' : str(district.name), 'gid' : int(district.gid), 'the_geom' : json.loads(district.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

##########################
##FILTERS
##########################

#def filter_county_by_name(request, county_name):
#
#    if county_name == "All":
#        counties = OhioCounties.objects.all()
#        countyIds = map(lambda county: county.gid, counties)
#
#        return render_to_response('json/base.json', {'json': json.dumps(countyIds)}, context_instance=RequestContext(request))
#    else:
#        county = OhioCounties.objects.get(name=county_name)
#        return render_to_response('json/base.json', {'json': json.dumps([county.gid])}, context_instance=RequestContext(request))
#
#def filter_org_by_type(request, type_name):
#
#    if type_name == "All":
#        orgs = GiseduOrg.objects.all()
#        orgIds = map(lambda org: org.gid, orgs)
#
#        return render_to_response('json/base.json', {'json': json.dumps(orgIds)}, context_instance=RequestContext(request))
#    else:
#        orgs = GiseduOrg.objects.filter(org_type__org_type_name=type_name)
#        orgIds = map(lambda org: org.gid, orgs)
#
#        return render_to_response('json/base.json', {'json': json.dumps(orgIds)}, context_instance=RequestContext(request))
#
#def filter_org_by_name(request, org_name):
#
#    orgs = GiseduOrg.objects.filter(org_nm=org_name)
#    orgIds = map(lambda org: org.gid, orgs)
#
#    return render_to_response('json/base.json', {'json': json.dumps(orgIds)}, context_instance=RequestContext(request))
#
#def filter_school_district_by_name(request, name):
#
#    school_districts = []
#    if name == "All":
#        school_districts = OhioSchoolDistricts.objects.all()
#    else:
#        school_districts = OhioSchoolDistricts.objects.filter(name=name)
#
#    school_district_ids = map(lambda sd: sd.gid, school_districts)
#    return render_to_response('json/base.json', {'json': json.dumps(school_district_ids)}, context_instance=RequestContext(request))
#
#def intersect_org_type__county_name(request, org_type, county_name):
#
#    if county_name == "All":
#        orgs = GiseduOrg.objects.all()
#    else:
#        county = OhioCounties.objects.get(name=county_name)
#
#        if org_type == "All":
#            orgs = GiseduOrg.objects.all()
#            orgs = orgs.filter(the_geom__within=county.the_geom)
#        else:
#            orgs = GiseduOrg.objects.filter(org_type__org_type_name=org_type)
#            orgs = orgs.filter(the_geom__within=county.the_geom)
#
#    return render_to_response('json/base.json', {'json': json.dumps(map(lambda org: org.gid, orgs))},
#                                  context_instance=RequestContext(request))
#
#def intersect_org_type__school_district_name(request, org_type, school_district_name):
#
#    if school_district_name == "All":
#        orgs = GiseduOrg.objects.all()
#    else:
#        school_district = OhioSchoolDistricts.objects.get(name=school_district_name)
#
#        if org_type == "All":
#            orgs = GiseduOrg.objects.all()
#            orgs = orgs.filter(the_geom__within=school_district.the_geom)
#        else:
#            orgs = GiseduOrg.objects.filter(org_type__org_type_name=org_type)
#            orgs = orgs.filter(the_geom__within=school_district.the_geom)
#
#
#    return render_to_response('json/base.json', {'json': json.dumps(map(lambda org: org.gid, orgs))},
#                                  context_instance=RequestContext(request))