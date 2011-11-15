# Create your views here.
import json
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from filters.models import GiseduFilters
from point_objects.models import GiseduPointItem, GiseduPointItemBooleanFields, GiseduPointItemIntegerFields, GiseduPointItemStringFields

@csrf_exempt
def point_geom_list(request, data_type):
    """
    Responds to a post request containing a list of Point Item PKs by returning a list corresponding to each item's geometry field stored in the database.
    TODO: Make another function that responds to single items(vs. the list of them) for access via HTTP.
    """
    jsonObj = simplejson.loads(request.raw_post_data)
    point_ids = jsonObj['point_ids']

    gis_filter = GiseduFilters.objects.get(pk=data_type)
    point_objects = GiseduPointItem.objects.filter(filter=gis_filter)
    point_objects = point_objects.filter(pk__in=point_ids)
    object_result = dict([(x.pk, json.loads(x.the_geom.json)) for x in point_objects])

    return render_to_response('json/base.json', {'json': json.dumps(object_result)}, context_instance=RequestContext(request))


def point_infobox_by_type(request, data_type, point_id):
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
