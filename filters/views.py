# Create your views here.
from _collections import defaultdict
import json
import string
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from models import GiseduFilters
from gisedu.models import GiseduPolygonItem, GiseduPolygonItemCharField, GiseduPolygonItemBooleanField, \
    GiseduPolygonItemIntegerField, GiseduPointItem, GiseduPointItemBooleanField, GiseduPointItemCharField, \
    GiseduPointItemIntegerField, GiseduReduceItem, GiseduIntegerField, GiseduCharField, GiseduBooleanField
from point_objects.models import GiseduJointVocationalSchoolDistrict

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

    key_filter = queries[0]
    queries = queries[1:]

    print("Queries = " + str(queries))

    key_filter_options = {k : v for k, v in [string.split(x, '=') for x in string.split(key_filter, ':')]}

    polygon_filters = list(GiseduFilters.objects.filter(data_type="POLYGON"))

    for poly_filter in polygon_filters:
        if poly_filter.request_modifier in key_filter_options:
            filter_polygon(poly_filter, key_filter_options, query_results)

    point_filters = list(GiseduFilters.objects.filter(data_type="POINT"))

    for point_filter in point_filters:
        if point_filter.request_modifier in key_filter_options:
            if point_filter.filter_type == "LIST":
                filter_point(point_filter, key_filter_options, query_results, queries)
            elif point_filter.filter_type == "DICT":
                filter_point_by_type(point_filter, key_filter_options, query_results, queries)

    print "Query Results " + str(query_results)

    typeId_results = []
    for result in query_results:
        if isinstance(result, GiseduPolygonItem):
            typeId_results.append(str(result.filter_id) + ":" + str(result.pk))
        elif isinstance(result, GiseduPointItem):
            typeId_results.append(str(result.filter_id) + ":" + str(result.pk))
        elif isinstance(result, GiseduJointVocationalSchoolDistrict):
            typeId_results.append("joint_voc_sd:" + str(result.gid))

    return render_to_response('json/base.json', {'json' : json.dumps(typeId_results)}, context_instance=RequestContext(request))

def process_point_in_filter(key_objects, object):
    return key_objects.filter(the_geom__within=object.the_geom)

def filter_polygon(poly_filter, options, query_results, key_objects=None, object_filter=None):
    polygon_id = options[poly_filter.request_modifier]
    del options[poly_filter.request_modifier]
    options = {k : v for k, v in options.iteritems() if v != "All"}
    
    get_all = (polygon_id == "All")

    if get_all:
        poly_objects = GiseduPolygonItem.objects.filter(filter=poly_filter)
    else:
        poly_objects = [GiseduPolygonItem.objects.get(pk=polygon_id)]

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

    option_names = [name for name in options.iterkeys() if name in bool_options]
    option_values = [value for value in options.itervalues()]

    if len(option_names) > 0:
        boolean_fields = boolean_fields.filter(field__field_name__in=option_names)
        boolean_fields = boolean_fields.filter(field__field_value__in=option_values)
        print(len(list(boolean_fields)))
        filtered_poly_objects = [field.polygon for field in boolean_fields]
        poly_objects = set(poly_objects).intersection(set(filtered_poly_objects))
    #end reduce bool
            
    query_results.extend(poly_objects)

    #do spatial tests if needed
    if key_objects is not None and object_filter is not None and not get_all:
        key_objects_results = [object_filter(key_objects, item) for item in list(poly_objects)]
        return reduce(lambda x, y: x | y, key_objects_results)
    else:
        return query_results

def filter_point(point_filter, options, query_results, queries, key_objects=None, object_filter=None):
    point_id = options[point_filter.request_modifier]
    del options[point_filter.request_modifier]
    options = {k : v for k, v in options.iteritems() if v != "All"}

    get_all = (point_id == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = [GiseduPointItem.objects.get(pk=point_id)]

    point_objects = process_spatial_filters(point_objects, query_results, queries, process_point_in_filter)

    query_results.extend(process_point_reduce_filters(point_filter, point_objects, options))

    return query_results

def filter_point_by_type(point_filter, options, query_results, queries, key_objects=None, object_filter=None):
    point_subtype = options[point_filter.request_modifier]
    del options[point_filter.request_modifier]
    options = {k : v for k, v in options.iteritems() if v != "All"}
    get_all = (point_subtype == "All")

    if get_all:
        point_objects = GiseduPointItem.objects.filter(filter=point_filter)
    else:
        point_objects = GiseduPointItem.objects.filter(item_type=point_subtype)
        
    point_objects = process_spatial_filters(point_objects, query_results, queries, process_point_in_filter)

    query_results.extend(process_point_reduce_filters(point_filter, point_objects, options))

    return query_results

def process_point_reduce_boolean_filters(point_filter, point_objects, options):
    boolean_fields = GiseduPointItemBooleanField.objects.filter(point__filter=point_filter)
    bool_options = GiseduBooleanField.objects.values('field_name').distinct()
    bool_options = [option['field_name'] for option in bool_options]

    option_names = [name for name in options.iterkeys() if name in bool_options]
    option_values = [True if value.upper() == "TRUE" or value.upper() == "T" else False for value in options.itervalues()]

    if len(option_names) > 0:
        print("Bool Option Names " + str(option_names))
        boolean_fields = boolean_fields.filter(field__field_name__in=option_names)
        boolean_fields = boolean_fields.filter(field__field_value__in=option_values)
        print(len(list(boolean_fields)))
        filtered_point_objects = [field.point for field in boolean_fields]
        point_objects = set(point_objects).intersection(set(filtered_point_objects))

    return point_objects

def process_point_reduce_char_filters(point_filter, point_objects, options):
    char_fields = GiseduPointItemCharField.objects.filter(point__filter=point_filter)
    char_options = GiseduCharField.objects.values('field_name').distinct()
    char_options = [option['field_name'] for option in char_options]

    print("Char Options = " + str(char_options))

    option_names = [name for name in options.iterkeys() if name in char_options]
    option_values = [value for value in options.itervalues()]

    print("Option Values = " + str(option_values))

    if len(option_names) > 0:
        print("Char Option Names " + str(option_names))
        char_fields = char_fields.filter(field__field_name__in=option_names)
        char_fields = char_fields.filter(field__pk__in=option_values)
        print(len(list(char_fields)))
        filtered_point_objects = [field.point for field in char_fields]
        point_objects = set(point_objects).intersection(set(filtered_point_objects))

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

    print("Integer Options = " + str(integer_options))

    for name, value in options.iteritems():
        try:
            value = int(value)
        except ValueError as e:
            continue

        integer_query_option = string.split(name, "__")

        if len(integer_query_option) > 1:
            name = integer_query_option[0]
            integer_query_option = integer_query_option[1]
        else:
            integer_query_option = ""

        print("name:" + str(name) + " value:" + str(value))
        integer_fields = integer_fields.filter(field__field_name=name)

        if integer_query_option == "lt":
            integer_fields = integer_fields.filter(field__field_value__lt=value)
        elif integer_query_option == "gt":
            integer_fields = integer_fields.filter(field__field_value__gt=value)
        else:
            integer_fields = integer_fields.filter(field__field_value=value)

    if len(options) > 0:
        filtered_point_objects = [field.point for field in integer_fields]
        point_objects = set(point_objects).intersection(set(filtered_point_objects))

    return point_objects

def process_point_reduce_filters(point_filter, point_objects, options):

    point_objects = process_point_reduce_boolean_filters(point_filter, point_objects, options)
    point_objects = process_point_reduce_char_filters(point_filter, point_objects, options)
    point_objects = process_point_reduce_integer_filters(point_filter, point_objects, options)

    return point_objects

def process_spatial_filters(key_objects, query_results, queries, object_filter):
    print("Process Spatial Filters Key Objects = " + str(key_objects))
    print("Process Spatial Filters Query Results = " + str(query_results))

    print(queries)
    for query in queries:
        query_options = {k : v for k, v in [string.split(x, '=') for x in string.split(query, ':')]}

        print("Query Options " + str(query_options))
        for name, value in query_options.iteritems():
            if value == "All":
                gis_filter = GiseduFilters.objects.get(request_modifier=name)
                polygons = GiseduPolygonItem.objects.filter(filter=gis_filter)
                query_results.extend(polygons)
            else:
                gis_polygon = GiseduPolygonItem.objects.get(pk=value)
                query_results.append(gis_polygon)
                key_objects = key_objects.filter(the_geom__within=gis_polygon.the_geom)

    print("Process Spatial Filters Query Results Done = " + str(query_results))
    print("Process Spatial Filters Key Objects Done = " + str(key_objects))
    return key_objects