# Create your views here.
import csv
import json
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.gis.geos.geometry import GEOSGeometry
from django.contrib.gis.geos.point import Point
from django.http import HttpResponse, HttpResponseNotFound
from django.shortcuts import render_to_response
from django.views.decorators.csrf import csrf_exempt
from filters.models import GiseduFilters
from gisedu.models import GiseduStringAttributeOption
from point_objects.models import GiseduPointItemIntegerFields, GiseduPointItemBooleanFields, GiseduPointItemStringFields, GiseduPointItem, GiseduPointItemAddress
from polygon_objects.models import GiseduPolygonItemIntegerFields, GiseduPolygonItemBooleanFields, GiseduPolygonItemStringFields, GiseduPolygonItem

@csrf_exempt
def upload_csv(request):
    """ Converts an uploaded CSV file into a manageable JSON object to be sent back to the client """
    if request.method == "POST":
        for key, value in request.FILES.iteritems():
            fileReader = csv.DictReader(value, delimiter=',', quotechar='"')
            columnDict = {k : [] for k in fileReader.fieldnames}

            for row in fileReader:
                [columnDict[col].append(data) for col, data in row.iteritems()]

            return render_to_response('json/base.json', {'json': json.dumps(columnDict)})
    else:
        return HttpResponseNotFound(mimetype = 'application/json')

def import_csv(request):
    """ Handles the response that comes from the CSV Import Tool """
    if request.method == "POST":
        csv_data = json.loads(request.raw_post_data)
        print(str(csv_data))

#    schema = {
#        'geometry_type' : "POINT"/"POLYGON",
#        'filter_type' : int<filter_id>,
#        'op_type' : "INSERT"/"UPDATE",
        operation_type = csv_data['op_type']
        geometry_type = csv_data['geometry_type']
        data_filter = GiseduFilters.objects.get(pk=csv_data['filter_type'])
        match_sets = csv_data['match_sets']

        if data_filter.filter_type != geometry_type:
            return HttpResponseNotFound(mimetype = 'application/json')

        field_objects = None
        field_object_name = None

        if geometry_type == "POINT":
            field_objects = dict(INTEGER=GiseduPointItemIntegerFields, BOOL=GiseduPointItemBooleanFields,
                                 CHAR=GiseduPointItemStringFields)
            field_object_name = 'point'

        elif geometry_type == "POLYGON":
            field_objects = dict(INTEGER=GiseduPolygonItemIntegerFields, BOOL=GiseduPolygonItemBooleanFields,
                                 CHAR=GiseduPolygonItemStringFields)
            field_object_name = 'polygon'

        if field_objects is None:
            return HttpResponseNotFound(mimetype = 'application/json')


        data_formaters = dict(INTEGER=lambda x: int(x),
                              BOOL=lambda x: x[0] == "T" or x[0] == "t",
                              CHAR=lambda x: x)

        update_lambdas_data_objects = dict(POINT=lambda x, val: setattr(x, 'point', val),
                                POLYGON=lambda x, val: setattr(x, 'polygon', val),)

        update_lambdas = dict(INTEGER=lambda x, val: setattr(x, 'value', val),
                                BOOL=lambda x, val: setattr(x, 'value', val),
                                CHAR=lambda x, val: setattr(x, 'option',
                                   GiseduStringAttributeOption.objects.get(option=val)))

        field_lambda_val = dict(INTEGER=lambda x: int(x.value),
                                  BOOL=lambda x: bool(x.value),
                                  CHAR=lambda x: str(x.option.option))

        field_lambda_obj = dict(INTEGER=lambda x: getattr(x, field_object_name),
                                  BOOL=lambda x: getattr(x, field_object_name),
                                  CHAR=lambda x: getattr(x, field_object_name))

        if operation_type == "UPDATE":
#        op_type = UPDATE =>
#            'join_column' : [row_1_for_column, row_2_for_column, ...],
#            'join_attribute_filter' : int<filter_id>
            print("Performing operation UPDATE")
            join_filter = GiseduFilters.objects.get(pk=csv_data['join_attribute_filter'])
            join_columns = map(data_formaters[join_filter.data_type], csv_data['join_column'])

            print(str(join_columns))
            
            find_by_args = dict(INTEGER=dict(attribute_filter=join_filter, value__in=join_columns),
                                BOOL=dict(attribute_filter=join_filter, value__in=join_columns),
                                CHAR=dict(attribute_filter=join_filter, option__option__in=join_columns))

            #find_by = GiseduPointItemIntegerFields.objects.filter(attribute_filter=join_filter, value__in=join_columns)
            #objects= dict(map(lambda x: (x.value, x.point), list(find_by)))
            find_by = field_objects[join_filter.data_type].objects.filter(
                **find_by_args[join_filter.data_type]
            )

            #maps each join column's row data to point or polygon field (PointItemIntegerField(building_irn)=>point for example)
            objects = { field_lambda_val[join_filter.data_type](item) : field_lambda_obj[join_filter.data_type](item)
                            for item in list(find_by) }

#        'match_sets' : [
#            {'column_data' : [row_1_for_column, row_2_for_column, ...]
#             'attribute_filter' : int<filter_id>},
#            {'column_data' : [row_1_for_column, row_2_for_column, ...]
#             'attribute_filter' : int<filter_id>},
#            {'column_data' : [row_1_for_column, row_2_for_column, ...]
#             'attribute_filter' : int<filter_id>},
#            ...
#        ]
#   }
            for match in match_sets:
                attribute_filter = GiseduFilters.objects.get(pk=match['attribute_filter'])
                column_data = [data_formaters[attribute_filter.data_type](col) for col in match['column_data']]

                join_data = dict(zip(join_columns, column_data))
                for join_value, column_value in join_data.iteritems():
                    object = objects[join_value]

                    try:
                        filter_args = {'attribute_filter' : attribute_filter, field_object_name : object}
                        attributes = field_objects[attribute_filter.data_type].objects.filter(**filter_args)

                        [update_lambdas[attribute_filter.data_type](attribute, column_value) for attribute in attributes]
                        [attribute.save() for attribute in attributes]

                    except Exception as e:
                        print(str(e))

            return HttpResponse(mimetype = 'application/json')
        elif operation_type == "INSERT":
            print("Processing INSERT operation")
            address_names_map = dict(street_address='address_line_one', city='city', state='state', zip='zip10')

            required_names = []
            address_names = []
            
            if geometry_type == "POINT":
                required_names = ['item_name', 'latitude', 'longitude']
                address_names = ['street_address', 'city', 'state', 'zip']

            elif geometry_type == "POLYGON":
                required_names = ['item_name', 'geometry']

            opt_names = required_names + ['item_type'] + address_names

            for item in required_names:
                if item not in csv_data:
                    print("Error: INSERT operation request is missing required parameters. "
                          + str(item) + " is not in " + str(list(csv_data.iterkeys())))
                    return HttpResponseNotFound(mimetype = 'application/json')

            names = [name for name in opt_names if name in csv_data]
            to_zip = [csv_data[name] for name in opt_names if name in csv_data]
            zip_list = zip(*to_zip)
            zip_list = [dict(zip(names, to_zip_item)) for to_zip_item in zip_list]

            new_objects = []
            
            if geometry_type == "POINT":
                print("Processing INSERT operation on POINT data")
                for item in zip_list:
                    new_point = GiseduPointItem()
                    new_point.filter = data_filter
                    new_point.item_name = item['item_name']
                    new_point.the_geom = Point(float(item['longitude']), float(item['latitude']))

                    if 'item_type' in item:
                        new_point.item_type = item['item_type']

                    address_items = { address_names_map[name] : item[name] if name in item else "" for name in address_names }

                    try:
                        item_address = GiseduPointItemAddress.objects.get(**address_items)
                        new_point.item_address = item_address
                    except ObjectDoesNotExist:
                        new_address = GiseduPointItemAddress(**address_items)

                        try:
                            new_address.save()
                        except Exception as e:
                            print(str(e))

                        new_point.item_address = new_address
                    except Exception as e:
                        print(str(e))

                    try:
                        new_point.save()
                    except Exception as e:
                        print(str(e))
                        
                    new_objects.append(new_point)

            elif geometry_type == "POLYGON":
                print("Processing INSERT operation on POLYGON data")
                for item in zip_list:
                    new_poly = GiseduPolygonItem()
                    new_poly.filter = data_filter
                    new_poly.item_name = item['item_name']
                    new_poly.the_geom = GEOSGeometry(item['geometry'])

                    if 'item_type' in item:
                        new_poly.item_type = item['item_type']

                    new_poly.save()
                    new_objects.append(new_poly)


            print("Processing attribute matches on INSERT operation")
            for match in match_sets:
                attribute_filter = GiseduFilters.objects.get(pk=match['attribute_filter'])
                column_data = [data_formaters[attribute_filter.data_type](col) for col in match['column_data']]

                object_data = dict(zip(new_objects, column_data))
                for object, column_value in object_data.iteritems():
                    try:
                        new_attribute = field_objects[attribute_filter.data_type]()
                        update_lambdas[attribute_filter.data_type](new_attribute, column_value)
                        update_lambdas_data_objects[data_filter.filter_type](new_attribute, object)
                        new_attribute.save()
                    except Exception as e:
                        print(str(e))

            return HttpResponse(mimetype = 'application/json')

    return HttpResponseNotFound(mimetype = 'application/json')
