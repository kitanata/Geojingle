# Create your views here.
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from filters.models import GiseduFilters
from gisedu.models import GiseduPolygonItem

def browser_test(request):
    return render_to_response('browser_test.html', context_instance=RequestContext(request))

def index(request):
    return render_to_response('index.html', context_instance=RequestContext(request))

def google_map(request):
    return render_to_response('map.html', context_instance=RequestContext(request))

#def list_by_type(request, list_type, type_id):
#    list_data = None
#
#    if list_type == "organization":
#        orgs = GiseduOrg.objects.filter(org_type=type_id)
#        org_names = map(lambda org: str(org.org_nm), orgs)
#        org_ids = map(lambda org: org.gid, orgs)
#        list_data = dict(zip(org_ids, org_names))
#
#    elif list_type == "school":
#        schools = GiseduSchool.objects.filter(school_type=type_id)
#        school_names = map(lambda school: str(school.school_name), schools)
#        school_ids = map(lambda school: school.gid, schools)
#        list_data = dict(zip(school_ids, school_names))
#
#    return render_to_response('json/base.json', {'json': json.dumps(list_data)}, context_instance=RequestContext(request))

def polygon_geom(request, data_type, polygon_id):
    polygon = GiseduPolygonItem.objects.get(pk=polygon_id)
    response = json.dumps({'name' : str(polygon.item_name), 'gid' : int(polygon.pk), 'the_geom' : json.loads(polygon.the_geom.json)})
    return render_to_response('json/base.json', {'json': response}, context_instance=RequestContext(request))

@csrf_exempt
def polygon_geom_list(request, data_type):
    jsonObj = simplejson.loads(request.raw_post_data)
    poly_ids = jsonObj['polygon_ids']

    gis_filter = GiseduFilters.objects.get(pk=data_type)
    poly_objects = GiseduPolygonItem.objects.filter(filter=gis_filter)
    poly_objects = poly_objects.filter(pk__in=poly_ids)
    object_result = dict([(x.pk, json.loads(x.the_geom.json)) for x in poly_objects])

    print(object_result)

    return render_to_response('json/base.json', {'json': json.dumps(object_result)}, context_instance=RequestContext(request))

