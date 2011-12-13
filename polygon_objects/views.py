# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponseNotFound
from filters.models import GiseduFilters
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemIntegerFields

@csrf_exempt
def polygon_geom_list(request, data_type):
    """
    Responds to a post request containing a list of Polygon Item PKs by returning a list corresponding to each item's geometry field stored in the database.
    """
    jsonObj = simplejson.loads(request.raw_post_data)
    poly_ids = jsonObj['polygon_ids']

    gis_filter = GiseduFilters.objects.get(pk=data_type)
    poly_objects = GiseduPolygonItem.objects.filter(filter=gis_filter)
    poly_objects = poly_objects.filter(pk__in=poly_ids)
    object_result = dict([(x.pk, json.loads(x.the_geom.json)) for x in poly_objects])

    return render_to_response('json/base.json', {'json': json.dumps(object_result)}, context_instance=RequestContext(request))

def colorize_integer(request):
    """
    Processes a single POST COLORIZE_INTEGER filter on a list of polygon ids and returns each ID's normalized scaled
    color value between a specified range. Used to apply color gradients to data sets
    """

    print(request.method)
    if request.method == "POST":
        jsonObj = simplejson.loads(request.raw_post_data)
        print(jsonObj)
        reduce_filter = GiseduFilters.objects.get(pk=jsonObj['reduce_filter'])
        min_color = jsonObj['minimum_color']
        max_color = jsonObj['maximum_color']
        polygon_ids = jsonObj['object_ids']

        polygon_fields = GiseduPolygonItemIntegerFields.objects.filter(attribute_filter=reduce_filter)
        polygon_fields = list(polygon_fields.filter(polygon__pk__in=polygon_ids))
        polygon_fields = { field.polygon.pk : field.value for field in polygon_fields }

        if len(polygon_fields) == 0:
            return HttpResponseNotFound()

        print("Is it even getting here?")
        min_value = min(polygon_fields.itervalues())
        max_value = max(polygon_fields.itervalues())
        value_range = max_value - min_value

        print("Is it even getting here?")
        if value_range == 0:
            polygon_fields = { k : min_color for k, v in polygon_fields }
        else:
            for key, value in polygon_fields.iteritems():
                tf = (value - min_value) / float(value_range)
                polygon_fields[key] = [(c1 - c0) * tf + c0 for c1, c0 in zip(max_color, min_color)]

        return render_to_response('json/base.json', {'json': json.dumps(polygon_fields)})

    return HttpResponseNotFound(mimetype = 'application/json')
