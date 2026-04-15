import json
import uuid
import random
from datetime import datetime

def handler(event, context):
    """
    AWS Lambda handler for payment processing.
    This replaces the /api/payments/process endpoint.
    """
    try:
        # 1. Parse input
        body = json.loads(event.get('body', '{}'))
        user_id = body.get('userId')
        amount = body.get('amount')
        card_number = body.get('cardNumber', '')

        if not user_id or amount is None:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'userId and amount are required'})
            }

        # 2. Simulate validation
        if len(card_number.replace(" ", "")) != 16:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Card number must be 16 digits'})
            }

        # 3. Simulate payment processing (95% success)
        success = random.random() < 0.95
        status = "completed" if success else "failed"
        payment_id = str(uuid.uuid4())

        # 4. Response
        response_body = {
            'paymentId': payment_id,
            'status': status,
            'amount': amount,
            'message': f"Payment of ${amount:.2f} {'completed successfully' if success else 'failed'}.",
            'processedAt': datetime.utcnow().isoformat()
        }

        return {
            'statusCode': 200 if success else 402,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error', 'error': str(e)})
        }
