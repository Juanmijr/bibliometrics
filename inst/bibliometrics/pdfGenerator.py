import pandas as pd
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle
from reportlab.lib import colors

def calculate_page_width(data, canvas):
    """Calcula el ancho necesario para la página en función del contenido."""
    max_width = 0
    for row in data:
        for cell in row:
            width = canvas.stringWidth(cell, 'Helvetica', 10)
            max_width = max(max_width, width)
    return max_width + 1500  # Agrega margen

def generate_pdf_from_excel(df, output_pdf):
    df = df.astype(str)

    # Convertir DataFrame a lista de listas
    data = [df.columns.tolist()] + df.values.tolist()
    
    # Crear un canvas temporal para medir el ancho
    temp_canvas = canvas.Canvas("temp.pdf")
    page_width = calculate_page_width(data, temp_canvas)
    temp_canvas.save()
    
    # Ajustar el tamaño de la página en el PDF final
    pdf = SimpleDocTemplate(output_pdf, pagesize=(page_width, letter[1]))
    elements = []

    # Crear la tabla
    table = Table(data)
    
    # Estilo de la tabla
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('WORDWRAP', (0, 0), (-1, -1), True), 

    ]))

    # Añadir la tabla a los elementos del PDF
    elements.append(table)
    
    # Generar el PDF
    pdf.build(elements)
