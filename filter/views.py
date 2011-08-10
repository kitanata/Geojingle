# Create your views here.
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from gisedu.models import OhioCounties, OhioSchoolDistricts, OhioHouseDistricts, OhioSenateDistricts
from organizations.models import GiseduOrg
from schools.models import GiseduSchool

def parse_filter(request, filter_chain):
    queries = string.split(filter_chain, '/')

    query_results = []

    key_filter = queries[0]
    queries = queries[1:]

    key_filter_options = {k : v for k, v in [string.split(x, '=') for x in string.split(key_filter, ':')]}

    for filter_name, function in filter_function_mapping.iteritems():
        if filter_name in key_filter_options:
            function(key_filter_options, query_results)

    if 'school_by_type' in key_filter_options:
        filter_school_by_type(key_filter_options, queries, query_results)
    elif 'organization_by_type' in key_filter_options:
        filter_organization_by_type(key_filter_options, queries, query_results)

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


def process_school_in_filter(key_objects, object):
    return key_objects.filter(the_geom__within=object.the_geom)


def process_org_in_filter(key_objects, object):
    return key_objects.filter(the_geom__within=object.the_geom)


def filter_county(options, query_results, key_objects=None, object_filter=None):
    option_argument = options['county']
    get_all = (option_argument == "All")
    query_results.extend(get_query_results(OhioCounties.objects, get_all, pk=option_argument))

    if key_objects is not None and object_filter is not None:
        if not get_all:
            test_object = OhioCounties.objects.get(pk=option_argument)
            return object_filter(key_objects, test_object)
        else:
            return key_objects
    else:
        return query_results


def filter_school_district(options, query_results, key_objects=None, object_filter=None):
    option_argument = options['school_district']
    get_all = (option_argument == "All")

    if not get_all:
        sd_objects = OhioSchoolDistricts.objects.get(pk=option_argument)
    else:
        sd_objects = OhioSchoolDistricts.objects.all()

    if 'comcast' in options:
        comcast_argument = (options['comcast'].upper() == "TRUE" or options['comcast'].upper() == "T")
        sd_objects = sd_objects.filter(comcast_coverage=comcast_argument)
        query_results.extend(sd_objects)

        if key_objects is not None and object_filter is not None:
            key_objects_results = [object_filter(key_objects, dist) for dist in list(sd_objects)]
            return reduce(lambda x, y: x | y, key_objects_results)
        
    elif key_objects is not None and object_filter is not None and not get_all:
        query_results.extend([sd_objects])
        key_objects = object_filter(key_objects, sd_objects)
    else:
        query_results.extend(sd_objects)

    return key_objects


def filter_house_district(options, query_results, key_objects=None, object_filter=None):
    option_argument = options['house_district']
    get_all = (option_argument == "All")
    query_results.extend(get_query_results(OhioHouseDistricts.objects, get_all, pk=option_argument))

    if key_objects is not None and object_filter is not None:
        if not get_all:
            test_object = OhioHouseDistricts.objects.get(pk=option_argument)
            return object_filter(key_objects, test_object)
        else:
            return key_objects
    else:
        return query_results


def filter_senate_district(options, query_results, key_objects=None, object_filter=None):
    option_argument = options['senate_district']
    get_all = (option_argument == "All")
    query_results.extend(get_query_results(OhioSenateDistricts.objects, get_all, pk=option_argument))

    if key_objects is not None and object_filter is not None:
        if not get_all:
            test_object = OhioSenateDistricts.objects.get(pk=option_argument)
            return object_filter(key_objects, test_object)
        else:
            return key_objects
    else:
        return query_results


def filter_school_by_type(key_options, queries, query_results):
    key_argument = key_options['school_by_type']

    if key_argument == "All":
        key_objects = GiseduSchool.objects.all()
    else:
        key_objects = GiseduSchool.objects.filter(school_type__gid=key_argument)

    if 'broadband_greater' in key_options:
        key_objects = key_objects.filter(building_info__mbit__gte=key_options['broadband_greater'])
    elif 'broadband_less' in key_options:
        key_objects = key_objects.filter(building_info__mbit__lte=key_options['broadband_less'])

    if 'itc' in key_options:
        option_arg = key_options['itc']
        if option_arg != "All":
            key_objects = key_objects.filter(building_info__itc__gid=option_arg)

    if 'ode_class' in key_options:
        option_arg = key_options['ode_class']
        if option_arg != "All":
            key_objects = key_objects.filter(building_info__area_class__gid=option_arg)

    key_objects = process_spatial_filters(key_objects, query_results, queries, process_school_in_filter)
    query_results.extend(key_objects)
    
    return query_results


def filter_organization_by_type(key_options, queries, query_results):
    key_argument = key_options['organization_by_type']

    if key_argument == "All":
        key_objects = GiseduOrg.objects.all()
    else:
        key_objects = GiseduOrg.objects.filter(org_type__pk=key_argument)

    key_objects = process_spatial_filters(key_objects, query_results, queries, process_org_in_filter)
    query_results.extend(key_objects)

    return query_results


def process_spatial_filters(key_objects, query_results, queries, object_filter):
    print("Process Spatial Filters Key Objects = " + str(key_objects))
    print("Process Spatial Filters Query Results = " + str(query_results))
    for query in queries:
        query_options = {k : v for k, v in [string.split(x, '=') for x in string.split(query, ':')]}

        print("Query Options = " + str(query_options))
        
        for filter_name, function in filter_function_mapping.iteritems():
            if filter_name in query_options:
                print("Filter Name: " + filter_name + " Function:" + str(function))
                key_objects = function(query_options, query_results, key_objects, object_filter)

    print("Process Spatial Filters Query Results Done = " + str(query_results))
    print("Process Spatial Filters Key Objects Done = " + str(key_objects))
    return key_objects


filter_function_mapping = {
    'county' : filter_county,
    'house_district' : filter_house_district,
    'senate_district' : filter_senate_district,
    'school_district' : filter_school_district,
}