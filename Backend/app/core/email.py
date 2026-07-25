import aiosmtplib
from email.message import EmailMessage
from jinja2 import Environment
from jinja2 import FileSystemLoader

from app.core.config import settings


env = Environment(
    loader=FileSystemLoader("app/templates/email")
)


async def send_email(
    to_email: str,
    subject: str,
    template: str,
    **context,
):
    html = env.get_template(template).render(**context)

    message = EmailMessage()

    message["From"] = (
        f"{settings.EMAIL_FROM_NAME} <{settings.EMAIL_FROM}>"
    )

    message["To"] = to_email
    message["Subject"] = subject

    message.add_alternative(html, subtype="html")

    await aiosmtplib.send(
        message,
        hostname=settings.SMTP_HOST,
        port=settings.SMTP_PORT,
        username=settings.SMTP_USER,
        password=settings.SMTP_PASS,
        start_tls=True,
    )