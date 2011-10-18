# Create your views here.
from _collections import defaultdict
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.db.models import Q
from models import GiseduFilters
from gisedu.models import GiseduReduceItem, GiseduStringAttributeOption
from point_objects.models import GiseduPointItem, GiseduPointItemBooleanFields, GiseduPointItemIntegerFields, GiseduPointItemStringFields
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemBooleanFields, GiseduPolygonItemIntegerFields, GiseduPolygonItemStringFields

def filter_list(request):
    filter_objects = GiseduFilters.objects.filter(enabled=True)

    filter_data = {}

    for gis_filter in filter_objects:
        option_data = filter_options(gis_filter)
        filter_data[gis_filter.pk] = {  "id" : gis_filter.pk,
                                        "name" : gis_filter.description,
                                        "filter_type" : gis_filter.data_type, #database refactoring switched these
                                        "data_type" : gis_filter.filter_type, #todo: make client side code match this designation
                                        "request_modifier" : gis_filter.name,
                                        "option_filters" : [y.pk for y in list(gis_filter.option_filters.all())],
                                        "exclude_filters" : [y.pk for y in list(gis_filter.exclude_filters.all())],
                                        "filter_options" : option_data
        }

    return render_to_response('json/base.json', {'json': json.dumps(filter_data)}, context_instance=RequestContext(request))

def filter_options(gis_filter):
    list_data = None

    if gis_filter.filter_type == "POLYGON":
        polygon_items = GiseduPolygonItem.objects.filter(filter=gis_filter)
        list_data = dict([(item.pk, item.item_name) for item in polygon_items])

    elif gis_filter.filter_type == "POINT":
        point_items = GiseduPointItem.objects.filter(filter=gis_filter)

        if gis_filter.data_type == "LIST":
            list_data = dict([(item.pk, item.item_name) for item in point_items])
        elif gis_filter.data_type == "DICT":
            type_dict = defaultdict(dict)
            list_data = [(item.item_type, item.pk, item.item_name) for item in point_items]
            for k, pk, name in list_data:
                type_dict[k][pk] = name
            list_data = type_dict

    elif gis_filter.filter_type == "REDUCE":
        reduce_items = list(GiseduReduceItem.objects.filter(reduce_filter=gis_filter))

        polygon_field_managers = dict(INTEGER=GiseduPolygonItemIntegerFields, CHAR=GiseduStringAttributeOption, BOOL=GiseduPolygonItemBooleanFields)
        point_field_managers = dict(INTEGER=GiseduPointItemIntegerFields, CHAR=GiseduStringAttributeOption, BOOL=GiseduPointItemBooleanFields)

        for item in reduce_items:
            target_filter = item.target_filter

            if target_filter.filter_type == "POINT":
                point_objects = GiseduPointItem.objects.filter(filter=target_filter)
                field_manager = point_field_managers[gis_filter.data_type]
                
                if field_manager == GiseduStringAttributeOption:
                    reduce_fields = field_manager.objects.filter(attribute_filter=gis_filter)
                    list_data = {item.pk : item.option for item in reduce_fields}
                else:
                    reduce_fields = field_manager.objects.filter(point__in=point_objects)
                    reduce_fields = reduce_fields.filter(attribute_filter=item.reduce_filter).values('value').distinct()
                    list_data = [str(item['value']) for item in reduce_fields]

            elif target_filter.filter_type == "POLYGON":
                polygon_objects = GiseduPolygonItem.objects.filter(filter=target_filter)
                field_manager = polygon_field_managers[gis_filter.data_type]

                if field_manager == GiseduStringAttributeOption:
                    reduce_fields = field_manager.objects.filter(attribute_filter=gis_filter)
                    list_data = {item.pk : item.option for item in reduce_fields}
                else:
                    reduce_fields = field_manager.objects.filter(polygon__in=polygon_objects)
                    reduce_fields = reduce_fields.filter(attribute_filter=item.reduce_filter).values('value').distinct()
                    list_data = [str(item['value']) for item in reduce_fields]

    return list_data

def parse_filter(request, filter_chain):
    queries = string.split(filter_chain, '/')

    query_results = []

    print("Queries = " + str(queries))

    queries = [{k : v for k, v in [string.split(x, '=') for x in string.split(query, ':')]}
                    for query in queries]

    print("Queries = " + str(queries))
    
    polygon_filters = list(GiseduFilters.objects.filter(filter_type="POLYGON"))
    point_filters = list(GiseduFilters.objects.filter(filter_type="POINT"))

    polygon_request_modifiers = [f.name for f in polygon_filters]
    point_request_modifiers = [f.name for f in point_filters]

    print(str(polygon_request_modifiers))
    print(str(point_request_modifiers))

    polygon_results = []
    point_results = []
    for q in queries:
        for k, v in q.iteritems():
            if k in polygon_request_modifiers:
                poly_filter = GiseduFilters.objects.get(name=k)
                polygon_results.extend(filter_polygon(poly_filter, q))
            elif k in point_request_modifiers:
                point_filter = GiseduFilters.objects.get(name=k)
                if point_filter.data_type == "LIST":
                    point_results.extend(filter_point(point_filter, q))
                elif point_filter.data_type == "DICT":
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
    polygon_id = options[poly_filter.name]
    get_all = (polygon_id == "All")

    if get_all:
        poly_objects = GiseduPolygonItem.objects.filter(filter=poly_filter)
    else:
        poly_objects = GiseduPolygonItem.objects.filter(pk=polygon_id)

    boolean_fields = GiseduPolygonItemBooleanFields.objects.filter(polygon__in=poly_objects)
    string_fields = GiseduPolygonItemStringFields.objects.filter(polygon__in=poly_objects)
    integer_fields = GiseduPolygonItemIntegerFields.objects.filter(polygon__in=poly_objects)

    poly_objects = process_reduce_boolean_filters(boolean_fields, poly_objects, options, geom_type="POLYGON")
    poly_objects = process_reduce_string_filters(string_fields, poly_objects, options, geom_type="POLYGON")
    poly_objects = process_reduce_integer_filters(integer_fields, poly_objects, options, geom_type="POLYGON")

    return list(poly_objects)

def filter_point(point_filter, options):
    point_id = options[point_filter.name]
    get_all = (point_id == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = GiseduPointItem.objects.filter(pk=point_id)

    boolean_fields = GiseduPointItemBooleanFields.objects.filter(point__in=point_objects)
    string_fields = GiseduPointItemStringFields.objects.filter(point__in=point_objects)
    integer_fields = GiseduPointItemIntegerFields.objects.filter(point__in=point_objects)

    point_objects = process_reduce_boolean_filters(boolean_fields, point_objects, options)
    point_objects = process_reduce_string_filters(string_fields, point_objects, options)
    point_objects = process_reduce_integer_filters(integer_fields, point_objects, options)

    return list(point_objects)

def filter_point_by_type(point_filter, options):
    point_subtype = options[point_filter.name]
    get_all = (point_subtype == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = GiseduPointItem.objects.filter(item_type=point_subtype)

    boolean_fields = GiseduPointItemBooleanFields.objects.filter(point__in=point_objects)
    string_fields = GiseduPointItemStringFields.objects.filter(point__in=point_objects)
    integer_fields = GiseduPointItemIntegerFields.objects.filter(point__in=point_objects)

    point_objects = process_reduce_boolean_filters(boolean_fields, point_objects, options)
    point_objects = process_reduce_string_filters(string_fields, point_objects, options)
    point_objects = process_reduce_integer_filters(integer_fields, point_objects, options)

    return list(point_objects)

def process_reduce_boolean_filters(fields, objects, options, geom_type="POINT"):
    bool_options = GiseduFilters.objects.filter(filter_type="REDUCE", data_type="BOOL")
    bool_options = [option.name for option in bool_options]

    options = {k : True if v.upper() == "TRUE" or v.upper() == "T" else False for k, v in options.iteritems() if k in bool_options}

    for name, value in options.iteritems():
        print("Name " + str(name) + " Value: " + str(value))
        filter_fields = fields.filter(attribute_filter__name=name, value=value)

        if geom_type == "POINT":
            objects = objects.filter(pk__in=[item.point.pk for item in filter_fields])
        elif geom_type == "POLYGON":
            objects = objects.filter(pk__in=[item.polygon.pk for item in filter_fields])

    return objects

def process_reduce_string_filters(fields, objects, options, geom_type="POINT"):
    string_options = GiseduFilters.objects.filter(filter_type="REDUCE", data_type="CHAR")
    string_options = [option.name for option in string_options]

    options = {k : v for k, v in options.iteritems() if k in string_options}

    for name, value in options.iteritems():
        filter_fields = fields.filter(attribute_filter__name=name)
        filter_fields = filter_fields.filter(option__pk=value)

        if geom_type == "POINT":
            objects = objects.filter(pk__in=[item.point.pk for item in filter_fields])
        elif geom_type == "POLYGON":
            objects = objects.filter(pk__in=[item.polygon.pk for item in filter_fields])
    return objects

#Integer Filters
def process_reduce_integer_filters(fields, objects, options, geom_type="POINT"):
    integer_options = GiseduFilters.objects.filter(filter_type="REDUCE", data_type="INTEGER")
    integer_options = [option.name for option in integer_options]

    integer_options.extend([option + "__lt" for option in integer_options])
    integer_options.extend([option + "__gt" for option in integer_options])
    integer_options.extend([option + "__eq" for option in integer_options])

    options = {k:v for k, v in options.iteritems() if k in integer_options}

    print("Process Integer Filters")
    object_keys = []
    for name, value in options.iteritems():
        integer_query_option = string.split(name, "__")

        if len(integer_query_option) > 1:
            name = integer_query_option[0]
            integer_query_option = integer_query_option[1]
        else:
            integer_query_option = ""

        filter_fields = fields.filter(attribute_filter__name=name)

        if integer_query_option == "lt":
            filter_fields = filter_fields.filter(value__lt=value)
        elif integer_query_option == "gt":
            filter_fields = filter_fields.filter(value__gt=value)
        else:
            filter_fields = filter_fields.filter(value=value)

        if geom_type == "POINT":
            objects = objects.filter(pk__in=[item.point.pk for item in filter_fields])
        elif geom_type == "POLYGON":
            objects = objects.filter(pk__in=[item.polygon.pk for item in filter_fields])

    return objects