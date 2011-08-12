# Create your views here.
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json
from gisedu.models import OhioHouseDistricts, OhioSenateDistricts
from models import OhioCounties, OhioSchoolDistricts
from point_objects.models import SchoolItc, GiseduSchoolType, GiseduOrgType, \
        SchoolAreaClassification, GiseduJointVocationalSchoolDistrict, GiseduOrg, GiseduSchool

def browser_test(request):
    return render_to_response('browser_test.html', context_instance=RequestContext(request))

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def google_map(request):
    return render_to_response('map.html', context_instance=RequestContext(request))

def list(request, list_type):
    list_data = None

    if list_type == "county":
        counties = OhioCounties.objects.all()
        county_names = map(lambda county: str(county.name), counties)
        county_ids = map(lambda county: int(county.gid), counties)
        list_data = dict(zip(county_ids, county_names))

    elif list_type == "school_district":
        districts = OhioSchoolDistricts.objects.all()
        district_names = map(lambda district: str(district.name), districts)
        district_ids = map(lambda district: int(district.gid), districts)
        list_data = dict(zip(district_ids, district_names))

    elif list_type == "house_district":
        districts = OhioHouseDistricts.objects.all()
        house_names = map(lambda house: "{:03d}".format(int(house.district)), districts)
        house_ids = map(lambda house: house.gid, districts)
        list_data = dict(zip(house_ids, house_names))

    elif list_type == "senate_district":
        districts = OhioSenateDistricts.objects.all()
        senate_names = map(lambda senate: "{:03d}".format(int(senate.district)), districts)
        senate_ids = map(lambda senate: senate.gid, districts)
        list_data = dict(zip(senate_ids, senate_names))

    elif list_type == "organization":
        types = GiseduOrgType.objects.all()
        type_names = map(lambda type: str(type.org_type_name), types)
        type_ids = map(lambda type: int(type.gid), types)
        list_data = dict(zip(type_ids, type_names))

    elif list_type == "school":
        types = GiseduSchoolType.objects.all()
        type_names = map(lambda type: str(type.school_type), types)
        type_ids = map(lambda type: type.gid, types)
        list_data = dict(zip(type_ids, type_names))

    elif list_type == "school_itc":
        itcs = SchoolItc.objects.all()
        itc_names = map(lambda itc: str(itc.itc), itcs)
        itc_ids = map(lambda itc: itc.gid, itcs)
        list_data = dict(zip(itc_ids, itc_names))

    elif list_type == "ode_class":
        classes = SchoolAreaClassification.objects.all()
        ode_names = map(lambda cls: cls.classification, classes)
        ode_ids = map(lambda cls: cls.gid, classes)
        list_data = dict(zip(ode_ids, ode_names))

    elif list_type == "joint_voc_sd":
        jvsds = GiseduJointVocationalSchoolDistrict.objects.all()
        jvsd_names = map(lambda jvsd: jvsd.jvsd_name, jvsds)
        jvsd_ids = map(lambda jvsd: jvsd.gid, jvsds)
        list_data = dict(zip(jvsd_ids, jvsd_names))

    return render_to_response('json/base.json', {'json': json.dumps(list_data)}, context_instance=RequestContext(request))

def list_by_type(request, list_type, type_id):
    list_data = None

    if list_type == "organization":
        orgs = GiseduOrg.objects.filter(org_type=type_id)
        org_names = map(lambda org: str(org.org_nm), orgs)
        org_ids = map(lambda org: org.gid, orgs)
        list_data = dict(zip(org_ids, org_names))

    elif list_type == "school":
        schools = GiseduSchool.objects.filter(school_type=type_id)
        school_names = map(lambda school: str(school.school_name), schools)
        school_ids = map(lambda school: school.gid, schools)
        list_data = dict(zip(school_ids, school_names))

    return render_to_response('json/base.json', {'json': json.dumps(list_data)}, context_instance=RequestContext(request))

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