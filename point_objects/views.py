# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse, HttpResponseNotFound
from filters.models import GiseduFilters
from point_objects.models import GiseduPointItem, GiseduPointItemBooleanFields, GiseduPointItemIntegerFields, GiseduPointItemStringFields

def point_infobox(request, point_id):
    """
    Returns HTML to show for a specific point's infobox inside Google Maps.
    Currently returns address information as well as attribute information.
    """
    point_object = GiseduPointItem.objects.get(pk=point_id)

    boolean_fields = GiseduPointItemBooleanFields.objects.filter(point=point_object)
    boolean_fields = {str(field.value) : str(field.attribute_filter.description) for field in boolean_fields}

    integer_fields = GiseduPointItemIntegerFields.objects.filter(point=point_object)
    integer_fields = {str(field.value) : str(field.attribute_filter.description) for field in integer_fields}

    string_fields = GiseduPointItemStringFields.objects.filter(point=point_object)
    string_fields = {str(field.option.option) : str(field.attribute_filter.description) for field in string_fields}

    response = {
        'org_name' : point_object.item_name,
        'address' : point_object.item_address,
        'boolean_fields' : boolean_fields,
        'integer_fields' : integer_fields,
        'string_fields' : string_fields }
    
    return render_to_response('edu_org_info.html', response, context_instance=RequestContext(request))


@csrf_exempt
def point_scale_integer(request):
    """
    Processes a single POST SCALE_INTEGER filter on a list of point ids and returns the each ID's normalized
    scaled value. This is used for situations where you have a collection of point data and want to scale
    them based on some integer value
    """

    if request.method == "POST":
        jsonObj = json.loads(request.raw_post_data)
        reduce_filter = GiseduFilters.objects.get(pk=jsonObj['reduce_filter'])
        min_scale = jsonObj['minimum_scale']
        max_scale = jsonObj['maximum_scale']
        point_ids = jsonObj['object_ids']

        point_fields = GiseduPointItemIntegerFields.objects.filter(attribute_filter=reduce_filter)
        point_fields = list(point_fields.filter(point__pk__in=point_ids))
        point_fields = { field.point.pk : field.value for field in point_fields }

        if len(point_fields) == 0:
            return HttpResponseNotFound()

        min_value = min(point_fields.itervalues())
        max_value = max(point_fields.itervalues())

        value_range = max_value - min_value
        scale_range = max_scale - min_scale

        if value_range == 0:
            point_fields = { k : min_scale for k, v in point_fields }
        else:
            for key, value in point_fields.iteritems():
                tf = (value - min_value) / float(value_range)
                point_fields[key] = scale_range * tf + min_scale

        return HttpResponse(json.dumps(point_fields), mimetype = 'application/json')

    return HttpResponseNotFound(mimetype = 'application/json')


@csrf_exempt
def colorize_integer(request):
    """
    Processes a single POST COLORIZE_INTEGER filter on a list of point ids and returns each ID's normalized scaled
    color value between a specified range. Used to apply color gradients to data sets
    """

    if request.method == "POST":
        jsonObj = json.loads(request.raw_post_data)
        reduce_filter = GiseduFilters.objects.get(pk=jsonObj['reduce_filter'])
        min_color = jsonObj['minimum_color']
        max_color = jsonObj['maximum_color']
        point_ids = jsonObj['object_ids']

        point_fields = GiseduPointItemIntegerFields.objects.filter(attribute_filter=reduce_filter)
        point_fields = list(point_fields.filter(point__pk__in=point_ids))
        point_fields = { field.point.pk : field.value for field in point_fields }

        if len(point_fields) == 0:
            return HttpResponseNotFound()

        min_value = min(point_fields.itervalues())
        max_value = max(point_fields.itervalues())
        value_range = max_value - min_value

        if value_range == 0:
            point_fields = { k : min_color for k, v in point_fields }
        else:
            for key, value in point_fields.iteritems():
                tf = (value - min_value) / float(value_range)
                point_fields[key] = [(c1 - c0) * tf + c0 for c1, c0 in zip(max_color, min_color)]

        return HttpResponse(json.dumps(point_fields), mimetype = 'application/json')

    return HttpResponseNotFound(mimetype = 'application/json')


