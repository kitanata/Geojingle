# Create your views here.
from _collections import defaultdict
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.db.models import Q
from models import GiseduFilters
from gisedu.models import GiseduReduceItem, GiseduIntegerField, GiseduCharField, GiseduBooleanField
from point_objects.models import GiseduPointItem, GiseduPointItemIntegerField, GiseduPointItemCharField, GiseduPointItemBooleanField
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemIntegerField, GiseduPolygonItemCharField, GiseduPolygonItemBooleanField

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

        point_types = dict(INTEGER=GiseduPointItemIntegerField, CHAR=GiseduPointItemCharField,
                           BOOL=GiseduPointItemBooleanField)

        polygon_types = dict(INTEGER=GiseduPolygonItemIntegerField, CHAR=GiseduPolygonItemCharField,
                             BOOL=GiseduPolygonItemBooleanField)

        field_types = dict(INTEGER=GiseduIntegerField, CHAR=GiseduCharField, BOOL=GiseduBooleanField)

        for item in reduce_items:
            target_filter = item.target_filter
            item_field = item.item_field
            reduce_fields = None

            if target_filter.data_type == "POINT":
                field_manager = point_types[gis_filter.filter_type]
                if field_manager is not None:
                    reduce_fields = field_manager.objects.filter(point__filter=target_filter)

            elif target_filter.data_type == "POLYGON":
                field_manager = polygon_types[gis_filter.filter_type]
                if field_manager is not None:
                    reduce_fields = field_manager.objects.filter(polygon__filter=target_filter)

            if reduce_fields is not None:
                reduce_fields = reduce_fields.values('field_id').distinct()
                reduce_fields = field_types[gis_filter.filter_type].objects.filter(pk__in=reduce_fields)
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

    poly_objects = set(poly_objects)
    print("Poly Objects = " + str(poly_objects))
    print(str(options))

    #TODO implement Integer based Field Filters and Char based Field Filters
    #TODO Bool is done here for now
    #start reduce bool

#    bool_options = [field['field_name'] for field in bool_options]
#
#    #filter down the polygon objects
#    for field_name in bool_options:
#        if field_name in options:
#            opt_arg = (options[field_name].upper() == "TRUE" or options[field_name].upper() == "T")
#            filtered_poly_objects = [field.polygon for field in
#                boolean_fields.filter(field_name=field_name).filter(field_value=opt_arg)]
#            poly_objects = set(poly_objects).intersection(set(filtered_poly_objects))

    boolean_fields = GiseduPolygonItemBooleanField.objects.filter(polygon__filter=poly_filter)
    bool_options = GiseduBooleanField.objects.values('field_name').distinct()
    bool_options = [option['field_name'] for option in bool_options]

    options = {k : v for k, v in options.iteritems() if k in bool_options }

    print("Polygon boolean options = " + str(options))

    filtered_poly_objects = []
    for field_name, field_value in options.iteritems():
        boolean_fields = boolean_fields.filter(field__field_name=field_name)
        boolean_fields = boolean_fields.filter(field__field_value=field_value)

    if len(options) > 0:
        filtered_poly_objects = [field.polygon for field in boolean_fields]
        poly_objects = poly_objects.intersection(set(filtered_poly_objects))
            
    return list(poly_objects)

def filter_point(point_filter, options):
    point_id = options[point_filter.request_modifier]
    get_all = (point_id == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = [GiseduPointItem.objects.get(pk=point_id)]

    point_objects = set(point_objects)

    point_objects = process_point_reduce_boolean_filters(point_filter, point_objects, options)
    point_objects = process_point_reduce_char_filters(point_filter, point_objects, options)
    point_objects = process_point_reduce_integer_filters(point_filter, point_objects, options)

    return list(point_objects)

def filter_point_by_type(point_filter, options):
    point_subtype = options[point_filter.request_modifier]
    get_all = (point_subtype == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = GiseduPointItem.objects.filter(item_type=point_subtype)

    point_objects = set(point_objects)

    point_objects = process_point_reduce_boolean_filters(point_filter, point_objects, options)
    point_objects = process_point_reduce_char_filters(point_filter, point_objects, options)
    point_objects = process_point_reduce_integer_filters(point_filter, point_objects, options)

    return list(point_objects)

def process_point_reduce_boolean_filters(point_filter, point_objects, options):
    boolean_fields = GiseduPointItemBooleanField.objects.filter(point__filter=point_filter)
    bool_options = GiseduBooleanField.objects.values('field_name').distinct()
    bool_options = [option['field_name'] for option in bool_options]

    option_names = [name for name in options.iterkeys() if name in bool_options]
    option_values = [True if value.upper() == "TRUE" or value.upper() == "T" else False for value in options.itervalues()]

    if len(option_names) > 0:
        boolean_fields = boolean_fields.filter(field__field_name__in=option_names)
        boolean_fields = boolean_fields.filter(field__field_value__in=option_values)
        filtered_point_objects = [field.point for field in boolean_fields]
        point_objects = point_objects.intersection(set(filtered_point_objects))

    return point_objects

def process_point_reduce_char_filters(point_filter, point_objects, options):
    char_fields = GiseduPointItemCharField.objects.filter(point__filter=point_filter)
    char_options = GiseduCharField.objects.values('field_name').distinct()
    char_options = [option['field_name'] for option in char_options]

    option_names = [name for name in options.iterkeys() if name in char_options]
    option_values = [value for value in options.itervalues()]

    if len(option_names) > 0:
        char_fields = char_fields.filter(field__field_name__in=option_names)
        char_fields = char_fields.filter(field__pk__in=option_values)
        filtered_point_objects = [field.point for field in char_fields]
        point_objects = point_objects.intersection(set(filtered_point_objects))

    return point_objects

def process_point_reduce_integer_filters(point_filter, point_objects, options):
    integer_fields = GiseduPointItemIntegerField.objects.filter(point__filter=point_filter)
    integer_options = GiseduIntegerField.objects.values('field_name').distinct()
    integer_options = [option['field_name'] for option in integer_options]

    lt_integer_options = [option + "__lt" for option in integer_options]
    gt_integer_options = [option + "__gt" for option in integer_options]
    eq_integer_options = [option + "__eq" for option in integer_options]

    integer_options.extend(lt_integer_options)
    integer_options.extend(gt_integer_options)
    integer_options.extend(eq_integer_options)

    options = {k:v for k, v in options.iteritems() if k in integer_options}

    for name, value in options.iteritems():
        integer_query_option = string.split(name, "__")

        if len(integer_query_option) > 1:
            name = integer_query_option[0]
            integer_query_option = integer_query_option[1]
        else:
            integer_query_option = ""

        integer_fields = integer_fields.filter(field__field_name=name)

        if integer_query_option == "lt":
            integer_fields = integer_fields.filter(field__field_value__lt=value)
        elif integer_query_option == "gt":
            integer_fields = integer_fields.filter(field__field_value__gt=value)
        else:
            integer_fields = integer_fields.filter(field__field_value=value)

    if len(options) > 0:
        filtered_point_objects = [field.point for field in integer_fields]
        point_objects = point_objects.intersection(set(filtered_point_objects))

    return point_objects