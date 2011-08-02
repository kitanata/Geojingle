# Create your views here.
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json
from gisedu.models import OhioHouseDistricts, OhioSenateDistricts
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

def house_district_list(request):
    districts = OhioHouseDistricts.objects.all()
    house_names = map(lambda house: "{:03d}".format(int(house.district)), districts)
    house_ids = map(lambda house: house.gid, districts)
    districts = dict(zip(house_names, house_ids))
    return render_to_response('json/base.json', {'json' : json.dumps(districts)}, context_instance=RequestContext(request))

def senate_district_list(request):
    districts = OhioSenateDistricts.objects.all()
    senate_names = map(lambda senate: "{:03d}".format(int(senate.district)), districts)
    senate_ids = map(lambda senate: senate.gid, districts)
    districts = dict(zip(senate_names, senate_ids))
    return render_to_response('json/base.json', {'json' : json.dumps(districts)}, context_instance=RequestContext(request))

def county(request, county_id):
    county = OhioCounties.objects.get(pk=county_id)
    response = json.dumps({'name' : str(county.name), 'gid' : int(county.gid), 'the_geom' : json.loads(county.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

def school_district(request, district_id):
    district = OhioSchoolDistricts.objects.get(pk=district_id)
    response = json.dumps({'name' : str(district.name), 'gid' : int(district.gid), 'the_geom' : json.loads(district.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

def house_district(request, district_id):
    district = OhioHouseDistricts.objects.get(pk=district_id)
    response = json.dumps({'name' : "{:03d}".format(district.district), 'gid' : int(district.gid), 'the_geom' : json.loads(district.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

def senate_district(request, district_id):
    district = OhioSenateDistricts.objects.get(pk=district_id)
    response = json.dumps({'name' : "{:03d}".format(district.district), 'gid' : int(district.gid), 'the_geom' : json.loads(district.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))