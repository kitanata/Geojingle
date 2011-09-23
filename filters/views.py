# Create your views here.
from _collections import defaultdict
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.db.models import Q
from models import GiseduFilters
from gisedu.models import GiseduReduceItem, GiseduIntegerField, GiseduCharField, GiseduBooleanAttribute
from point_objects.models import GiseduPointItem, GiseduPointItemBooleanFields
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemBooleanFields

def filter_list(request):
    filter_objects = GiseduFilters.objects.all()

    filter_data = {}

    for gis_filter in filter_objects:
        option_data = filter_options(gis_filter)
        filter_data[gis_filter.pk] = {  "id" : gis_filter.gid,
                                        "name" : gis_filter.filter_name,
                                        "filter_type" : gis_filter.filter_type,
                                        "data_type" : gis_filter.data_type,
                                        "request_modifier" : gis_filter.request_modifier,
                                        "option_filters" : [y.gid for y in list(gis_filter.option_filters.all())],
                                        "exclude_filters" : [y.gid for y in list(gis_filter.exclude_filters.all())],
                                        "filter_options" : option_data
        }

    return render_to_response('json/base.json', {'json': json.dumps(filter_data)}, context_instance=RequestContext(request))

def filter_options(gis_filter):
    list_data = None

    if gis_filter.data_type == "POLYGON":
        polygon_items = GiseduPolygonItem.objects.filter(filter=gis_filter)
        list_data = dict([(item.pk, item.item_name) for item in polygon_items])

    elif gis_filter.data_type == "POINT":
        point_items = GiseduPointItem.objects.filter(filter=gis_filter)

        if gis_filter.filter_type == "LIST":
            list_data = dict([(item.pk, item.item_name) for item in point_items])
        elif gis_filter.filter_type == "DICT":
            type_dict = defaultdict(dict)
            list_data = [(item.item_type, item.pk, item.item_name) for item in point_items]
            for k, pk, name in list_data:
                type_dict[k][pk] = name
            list_data = type_dict

    elif gis_filter.data_type == "REDUCE":
        reduce_items = list(GiseduReduceItem.objects.filter(reduce_filter=gis_filter))

        field_types = dict(INTEGER=GiseduIntegerField, CHAR=GiseduCharField, BOOL=GiseduBooleanAttribute)

        for item in reduce_items:
            target_filter = item.target_filter
            item_field = item.item_field
            reduce_fields = None

            field_manager = field_types[gis_filter.filter_type]

            if target_filter.data_type == "POINT":
                point_objects = GiseduPointItem.objects.filter(filter=target_filter)
                if field_manager is not None:
                    if field_manager == GiseduBooleanAttribute:
                        reduce_fields = GiseduPointItemBooleanFields.objects.filter(point__in=point_objects).values('value').distinct()
                        list_data = [item['value'] for item in reduce_fields]
                    else:
                        reduce_fields = field_manager.objects.filter(gisedupointitem__in=point_objects)

                        reduce_fields = reduce_fields.filter(field_name=item_field)
                        list_data = dict([(item.pk, str(item.field_value)) for item in reduce_fields])

            elif target_filter.data_type == "POLYGON":
                polygon_objects = GiseduPolygonItem.objects.filter(filter=target_filter)
                if field_manager is not None:
                    if field_manager == GiseduBooleanAttribute:
                        reduce_fields = GiseduPolygonItemBooleanFields.objects.filter(polygon__in=polygon_objects).values('value').distinct()
                        list_data = [item['value'] for item in reduce_fields]
                    else:
                        reduce_fields = field_manager.objects.filter(gisedupolygonitem__in=polygon_objects)

                        reduce_fields = reduce_fields.filter(field_name=item_field)
                        list_data = dict([(item.pk, str(item.field_value)) for item in reduce_fields])

    return list_data

def parse_filter(request, filter_chain):
    queries = string.split(filter_chain, '/')

    query_results = []

    print("Queries = " + str(queries))

    queries = [{k : v for k, v in [string.split(x, '=') for x in string.split(query, ':')]}
                    for query in queries]

    print("Queries = " + str(queries))
    
    polygon_filters = list(GiseduFilters.objects.filter(data_type="POLYGON"))
    point_filters = list(GiseduFilters.objects.filter(data_type="POINT"))

    polygon_request_modifiers = [f.request_modifier for f in polygon_filters]
    point_request_modifiers = [f.request_modifier for f in point_filters]

    print(str(polygon_request_modifiers))
    print(str(point_request_modifiers))

    polygon_results = []
    point_results = []
    for q in queries:
        for k, v in q.iteritems():
            if k in polygon_request_modifiers:
                poly_filter = GiseduFilters.objects.get(request_modifier=k)
                polygon_results.extend(filter_polygon(poly_filter, q))
            elif k in point_request_modifiers:
                point_filter = GiseduFilters.objects.get(request_modifier=k)
                if point_filter.filter_type == "LIST":
                    point_results.extend(filter_point(point_filter, q))
                elif point_filter.filter_type == "DICT":
                    point_results.extend(filter_point_by_type(point_filter, q))

    point_pks = [point.pk for point in point_results]
    point_qs = GiseduPointItem.objects.filter(pk__in=point_pks)

    q_obj = Q()
    for polygon in polygon_results:
        q_obj |= Q(the_geom__within=polygon.the_geom)
    final_point_items = list(point_qs.filter(q_obj))

    query_results.extend(polygon_results)
    query_results.extend(final_point_items)
    print "Query Results " + str(query_results)

    typeId_results = []
    for result in query_results:
        if isinstance(result, GiseduPolygonItem):
            typeId_results.append(str(result.filter_id) + ":" + str(result.pk))
        elif isinstance(result, GiseduPointItem):
            typeId_results.append(str(result.filter_id) + ":" + str(result.pk))

    return render_to_response('json/base.json', {'json' : json.dumps(typeId_results)}, context_instance=RequestContext(request))

def filter_polygon(poly_filter, options):
    print("Polygon Options = " + str(options))
    polygon_id = options[poly_filter.request_modifier]
    get_all = (polygon_id == "All")

    if get_all:
        poly_objects = GiseduPolygonItem.objects.filter(filter=poly_filter)
    else:
        poly_objects = [GiseduPolygonItem.objects.get(pk=polygon_id)]

    boolean_fields = GiseduPolygonItemBooleanFields.objects.filter(polygon__in=poly_objects)
    char_fields = GiseduCharField.objects.filter(gisedupolygonitem__in=poly_objects)
    integer_fields = GiseduIntegerField.objects.filter(gisedupolygonitem__in=poly_objects)

    poly_objects = process_reduce_boolean_filters(boolean_fields, poly_objects, options, geom_type="POLYGON")
    poly_objects = process_reduce_char_filters(char_fields, poly_objects, options)
    poly_objects = process_reduce_integer_filters(integer_fields, poly_objects, options)

    return list(poly_objects)

def filter_point(point_filter, options):
    point_id = options[point_filter.request_modifier]
    get_all = (point_id == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = [GiseduPointItem.objects.get(pk=point_id)]

    boolean_fields = GiseduPointItemBooleanFields.objects.filter(point__in=point_objects)
    char_fields = GiseduCharField.objects.filter(gisedupointitem__in=point_objects)
    integer_fields = GiseduIntegerField.objects.filter(gisedupointitem__in=point_objects)

    point_objects = process_reduce_boolean_filters(boolean_fields, point_objects, options)
    point_objects = process_reduce_char_filters(char_fields, point_objects, options)
    point_objects = process_reduce_integer_filters(integer_fields, point_objects, options)

    return list(point_objects)

def filter_point_by_type(point_filter, options):
    point_subtype = options[point_filter.request_modifier]
    get_all = (point_subtype == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = GiseduPointItem.objects.filter(item_type=point_subtype)

    boolean_fields = GiseduPointItemBooleanFields.objects.filter(point__in=point_objects)
    char_fields = GiseduCharField.objects.filter(gisedupointitem__in=point_objects)
    integer_fields = GiseduIntegerField.objects.filter(gisedupointitem__in=point_objects)

    point_objects = process_reduce_boolean_filters(boolean_fields, point_objects, options)
    point_objects = process_reduce_char_filters(char_fields, point_objects, options)
    point_objects = process_reduce_integer_filters(integer_fields, point_objects, options)

    return list(point_objects)

def process_reduce_boolean_filters(fields, objects, options, geom_type="POINT"):
    bool_options = GiseduBooleanAttribute.objects.all()
    bool_options = [option.attribute_name for option in bool_options]

    options = {k : True if v.upper() == "TRUE" or v.upper() == "T" else False for k, v in options.iteritems() if k in bool_options}

    object_keys = []
    for name, value in options.iteritems():
        filter_fields = fields.filter(attribute__attribute_name=name)
        filter_fields = filter_fields.exclude(value=value)
        if geom_type == "POINT":
            object_keys.extend([item.point.pk for item in filter_fields])
        elif geom_type == "POLYGON":
            object_keys.extend([item.polygon.pk for item in filter_fields])

    objects = objects.exclude(pk__in=object_keys)

    return objects

def process_reduce_char_filters(field, objects, options):
    char_options = field.values('field_name').distinct()
    char_options = [option['field_name'] for option in char_options]

    options = {k : v for k, v in options.iteritems() if k in char_options}

    print("Process Char Filters")
    for name, value in options.iteritems():
        print("Name = " + str(name) + " Value = " + str(value))
        objects = objects.filter(string_fields__field_name=name, string_fields__pk=value)

    return objects

#Integer Filters
def process_reduce_integer_filters(fields, objects, options):
    integer_options = fields.values('field_name').distinct()
    integer_options = [option['field_name'] for option in integer_options]

    lt_integer_options = [option + "__lt" for option in integer_options]
    gt_integer_options = [option + "__gt" for option in integer_options]
    eq_integer_options = [option + "__eq" for option in integer_options]

    integer_options.extend(lt_integer_options)
    integer_options.extend(gt_integer_options)
    integer_options.extend(eq_integer_options)

    options = {k:v for k, v in options.iteritems() if k in integer_options}

    print("Process Integer Filters")
    for name, value in options.iteritems():
        print("Name = " + str(name) + " Value = " + str(value))
        integer_query_option = string.split(name, "__")

        if len(integer_query_option) > 1:
            name = integer_query_option[0]
            integer_query_option = integer_query_option[1]
        else:
            integer_query_option = ""

        if integer_query_option == "lt":
            objects = objects.filter(integer_fields__field_name=name, integer_fields__field_value__lt=value)
        elif integer_query_option == "gt":
            objects = objects.filter(integer_fields__field_name=name, integer_fields__field_value__gt=value)
        else:
            objects = objects.filter(integer_fields__field_name=name, integer_fields__field_value=value)

    return objects