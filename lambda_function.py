import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('imtech')

def lambda_handler(event, context):
    method = event.get('httpMethod')

    if not method:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing httpMethod – are you using Lambda Proxy Integration?'})
        }

    if method == 'POST':
        try:
            raw = json.loads(event.get('body') or '{}')
            table.put_item(Item={'id': 'some-id', 'data': raw})
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Stats uploaded'})
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps({'error': str(e)})
            }

    elif method == 'GET':
        try:
            resp = table.get_item(Key={'id': 'some-id'})
            if 'Item' in resp:
                return {
                    'statusCode': 200,
                    'body': json.dumps(resp['Item']['data'], default=str)
                }
            else:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'error': 'Stats not found'})
                }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps({'error': str(e)})
            }

    else:
        return {
            'statusCode': 405,
            'body': json.dumps({'error': f'Method {method} not allowed'})
        }
