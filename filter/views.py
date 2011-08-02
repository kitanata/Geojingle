# Create your views here.
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from gisedu.models import OhioCounties, OhioSchoolDistricts, OhioHouseDistricts, OhioSenateDistricts, OhioSchoolDistrictsComcastCoverage
from organizations.models import GiseduOrg
from schools.models import GiseduSchool

def parse_filter(request, filter_chain):
    print filter_chain
    queries = string.split(filter_chain, '/')

    query_results = []

    filter_key = queries[0]
    filter_key, filter_key_arg = string.split(filter_key, ':')
    queries = queries[1:]

    get_all = (filter_key_arg == "All")

    if filter_key == "county_by_name":
        query_results.extend(get_query_results(OhioCounties.objects, get_all, name=filter_key_arg))

    elif filter_key == "house_district":
        query_results.extend(get_query_results(OhioHouseDistricts.objects, get_all, pk=filter_key_arg))

    elif filter_key == "senate_district":
        query_results.extend(get_query_results(OhioSenateDistricts.objects, get_all, pk=filter_key_arg))

    elif filter_key == "school_district_by_name":
        query_results.extend(get_query_results(OhioSchoolDistricts.objects, get_all, name=filter_key_arg))

    elif filter_key == "school_by_type":
        query_results.extend(filter_school_by_type(filter_key_arg, queries))

    elif filter_key == "organization_by_type":
        query_results.extend(filter_organization_by_type(filter_key_arg, queries))

    print "Query Results " + str(query_results)

    typeId_results = []
    for result in query_results:
        if isinstance(result, OhioCounties):
            typeId_results.append("county:" + str(result.gid))
        elif isinstance(result, OhioHouseDistricts):
            typeId_results.append("house_district:" + str(result.gid))
        elif isinstance(result, OhioSenateDistricts):
            typeId_results.append("senate_district:" + str(result.gid))
        elif isinstance(result, OhioSchoolDistricts):
            typeId_results.append("school_district:" + str(result.gid))
        elif isinstance(result, GiseduSchool):
            typeId_results.append("school:" + str(result.gid))
        elif isinstance(result, GiseduOrg):
            typeId_results.append("org:" + str(result.gid))

    return render_to_response('json/base.json', {'json' : json.dumps(typeId_results)}, context_instance=RequestContext(request))


def get_query_results(object_manager, all=True, **kwargs):
    if all is True:
        return object_manager.all()
    else:
        return [object_manager.get(**kwargs)]

def process_school_in_filter(key_objects, object_manager, all=False, **kwargs):
    if all is False:
        object = object_manager.get(**kwargs)
        key_objects = key_objects.filter(org__the_geom__within=object.the_geom)

    return key_objects

def process_org_in_filter(key_objects, object_manager, all=False, **kwargs):
    if all is False:
        object = object_manager.get(**kwargs)
        key_objects = key_objects.filter(the_geom__within=object.the_geom)

    return key_objects

def filter_school_by_type(key_arg, queries):
    query_results = []

    if key_arg == "All":
        key_objects = GiseduSchool.objects.all()
    else:
        key_objects = GiseduSchool.objects.filter(school_type__gid=key_arg)

    for query in queries:
        key, arg = string.split(query, ':')

        get_all = (arg == "All")

        if key == "in_county":
            query_results.extend(get_query_results(OhioCounties.objects, get_all, name=arg))
            key_objects = process_school_in_filter(key_objects, OhioCounties.objects, get_all, name=arg)

        elif key == "in_school_district":
            query_results.extend(get_query_results(OhioSchoolDistricts.objects, get_all, name=arg))
            key_objects = process_school_in_filter(key_objects, OhioSchoolDistricts.objects, get_all, name=arg)
                
        elif key == "in_house_district":
            query_results.extend(get_query_results(OhioHouseDistricts.objects, get_all, pk=arg))
            key_objects = process_school_in_filter(key_objects, OhioHouseDistricts.objects, get_all, pk=arg)

        elif key == "in_senate_district":
            query_results.extend(get_query_results(OhioSenateDistricts.objects, get_all, pk=arg))
            key_objects = process_school_in_filter(key_objects, OhioSenateDistricts.objects, get_all, pk=arg)

        elif key == "with_broadband_greater":
            key_objects = key_objects.filter(building_info__mbit__gte=arg)

        elif key == "with_broadband_less":
            key_objects = key_objects.filter(building_info__mbit__lte=arg)

        elif key == "with_itc":
            if arg != "All":
                key_objects = key_objects.filter(building_info__itc__gid=arg)

        elif key == "with_ode_class":
            if arg != "All":
                key_objects = key_objects.filter(building_info__area_class__gid=arg)

        elif key == "with_comcast":
            query_results.extend(get_query_results(OhioSchoolDistrictsComcastCoverage.school_district.objects))
            key_objects = process_school_in_filter(key_objects, OhioSchoolDistrictsComcastCoverage.school_district.objects, get_all, name=arg)

    query_results.extend(key_objects)
    return query_results


def filter_organization_by_type(key_arg, queries):
    query_results = []
    
    if key_arg == "All":
        key_objects = GiseduOrg.objects.all()
    else:
        key_objects = GiseduOrg.objects.filter(org_type__org_type_name=key_arg)

    for query in queries:
        key, arg = string.split(query, ':')

        get_all = (arg == "All")

        if key == "in_county":
            query_results.extend(get_query_results(OhioCounties.objects, get_all, name=arg))
            key_objects = process_org_in_filter(key_objects, OhioCounties.objects, get_all, name=arg)

        elif key =="in_school_district":
            query_results.extend(get_query_results(OhioSchoolDistricts.objects, get_all, name=arg))
            key_objects = process_org_in_filter(key_objects, OhioSchoolDistricts.objects, get_all, name=arg)

        elif key == "in_house_district":
            query_results.extend(get_query_results(OhioHouseDistricts.objects, get_all, pk=arg))
            key_objects = process_org_in_filter(key_objects, OhioHouseDistricts.objects, get_all, pk=arg)

        elif key == "in_senate_district":
            query_results.extend(get_query_results(OhioSenateDistricts.objects, get_all, pk=arg))
            key_objects = process_org_in_filter(key_objects, OhioSenateDistricts.objects, get_all, pk=arg)

    query_results.extend(key_objects)
    return query_results