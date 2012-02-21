# Create your views here.
import json
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse, HttpResponseNotFound
from filters.models import GiseduFilters
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemIntegerFields

@csrf_exempt
def colorize_integer(request):
    """
    Processes a single POST COLORIZE_INTEGER filter on a list of polygon ids and returns each ID's normalized scaled
    color value between a specified range. Used to apply color gradients to data sets
    """

    print(request.method)
    if request.method == "POST":
        jsonObj = json.loads(request.raw_post_data)
        reduce_filter = GiseduFilters.objects.get(pk=jsonObj['reduce_filter'])
        min_color = jsonObj['minimum_color']
        max_color = jsonObj['maximum_color']
        polygon_ids = jsonObj['object_ids']

        polygon_fields = GiseduPolygonItemIntegerFields.objects.filter(attribute_filter=reduce_filter)
        polygon_fields = list(polygon_fields.filter(polygon__pk__in=polygon_ids))
        polygon_fields = { field.polygon.pk : field.value for field in polygon_fields }

        if len(polygon_fields) == 0:
            return HttpResponseNotFound(mimetype = 'application/json')

        min_value = min(polygon_fields.itervalues())
        max_value = max(polygon_fields.itervalues())
        value_range = max_value - min_value

        if value_range == 0:
            polygon_fields = { k : min_color for k, v in polygon_fields }
        else:
            for key, value in polygon_fields.iteritems():
                tf = (value - min_value) / float(value_range)
                polygon_fields[key] = [(c1 - c0) * tf + c0 for c1, c0 in zip(max_color, min_color)]

        return HttpResponse(json.dumps(polygon_fields), mimetype = 'application/json')

    return HttpResponseNotFound(mimetype = 'application/json')
