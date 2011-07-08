# Create your views here.
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from gisedu.models import OhioCounties, OhioSchoolDistricts
from organizations.models import GiseduOrg
from schools.models import GiseduSchool

def parse_filter(request, filter_chain):
    print filter_chain
    queries = string.split(filter_chain, '/')

    query_results = []

    filter_key = queries[0]
    filter_key, filter_key_arg = string.split(filter_key, ':')
    queries = queries[1:]

    if filter_key == "county_by_name":
        if filter_key_arg == "All":
            key_objects = OhioCounties.objects.all()
            query_results += key_objects
        else:
            county = OhioCounties.objects.get(name=filter_key_arg)
            query_results.append(county)

    elif filter_key == "school_district_by_name":
        if filter_key_arg == "All":
            key_objects = OhioSchoolDistricts.objects.all()
            query_results += key_objects
        else:
            school_district = OhioSchoolDistricts.objects.get(name=filter_key_arg)
            query_results.append(school_district)

    elif filter_key == "school_by_type":
        key_objects = GiseduSchool.objects.filter(school_type__school_type=filter_key_arg)
        for query in queries:
            key, arg = string.split(query, ':')
            if key == "in_county":
                if arg == "All":
                    counties = OhioCounties.objects.all()
                    query_results.extend(counties)
                else:
                    county = OhioCounties.objects.get(name=arg)
                    query_results.append(county)
                    key_objects = key_objects.filter(org__the_geom__within=county.the_geom)
            elif key =="in_school_district":
                if arg == "All":
                    school_districts = OhioSchoolDistricts.objects.all()
                    query_results.extend(school_districts)
                else:
                    school_dist = OhioSchoolDistricts.objects.get(name=arg)
                    query_results.append(school_dist)
                    key_objects = key_objects.filter(org__the_geom__within=school_dist.the_geom)
            elif key == "with_broadband_greater":
                key_objects = key_objects.filter(building_info__mbit__gte=arg)
            elif key == "with_broadband_less":
                key_objects = key_objects.filter(building_info__mbit__lte=arg)
        query_results.extend(key_objects)

    elif filter_key == "organization_by_type":
        if filter_key_arg == "All":
            key_objects = GiseduOrg.objects.all()
        else:
            key_objects = GiseduOrg.objects.filter(org_type__org_type_name=filter_key_arg)
        for query in queries:
            key, arg = string.split(query, ':')
            if key == "in_county":
                if arg == "All":
                    counties = OhioCounties.objects.all()
                    query_results.extend(counties)
                else:
                    county = OhioCounties.objects.get(name=arg)
                    query_results.append(county)
                    key_objects = key_objects.filter(the_geom__within=county.the_geom)
            elif key =="in_school_district":
                if arg == "All":
                    school_districts = OhioSchoolDistricts.objects.all()
                    query_results.extend(school_districts)
                else:
                    school_dist = OhioSchoolDistricts.objects.get(name=arg)
                    query_results.append(school_dist)
                    key_objects = key_objects.filter(the_geom__within=school_dist.the_geom)
        query_results.extend(key_objects)

    print "Query Results " + str(query_results)

    typeId_results = []
    for result in query_results:
        if isinstance(result, OhioCounties):
            typeId_results.append("county:" + str(result.gid))
        elif isinstance(result, OhioSchoolDistricts):
            typeId_results.append("school_district:" + str(result.gid))
        elif isinstance(result, GiseduSchool):
            typeId_results.append("school:" + str(result.gid))
        elif isinstance(result, GiseduOrg):
            typeId_results.append("org:" + str(result.gid))

    return render_to_response('json/base.json', {'json' : json.dumps(typeId_results)}, context_instance=RequestContext(request))