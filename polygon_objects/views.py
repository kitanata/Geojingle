# Create your views here.
from django.shortcuts import render_to_response
from django.template.context import RequestContext

import json
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from filters.models import GiseduFilters
from polygon_objects.models import GiseduPolygonItem

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

