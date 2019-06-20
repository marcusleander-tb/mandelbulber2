/*
 * palette_edit_widget.cpp
 *
 *  Created on: 1 cze 2019
 *      Author: krzysztof
 */

#include "gradient_edit_widget.h"

#include <QPainter>
#include <QMouseEvent>
#include <QColorDialog>
#include <QMenu>
#include <QInputDialog>
#include <QtWidgets>

#include "../src/error_message.hpp"
#include "preview_file_dialog.h"
#include "src/system.hpp"

cGradientEditWidget::cGradientEditWidget(QWidget *parent) : QWidget(parent)
{
	viewMode = false;
	mouseDragStarted = false;
	pressedColorIndex = 0;
	dragStartX = 0;

	int fixHeight = systemData.GetPreferredThumbnailSize() / 2;
	setFixedHeight(fixHeight);

	buttonWidth = fixHeight / 6;
	if (buttonWidth % 2 == 0) buttonWidth += 1; // to always have odd width

	margins = buttonWidth / 2 + 2;
}

cGradientEditWidget::~cGradientEditWidget()
{
	// TODO Auto-generated destructor stub
}

void cGradientEditWidget::SetViewModeOnly()
{
	viewMode = true;
	setFixedHeight(systemData.GetPreferredThumbnailSize() / 4);
	margins = 0;
}

void cGradientEditWidget::paintEvent(QPaintEvent *event)
{
	int gradientWidth = width() - 2 * margins;
	if (gradientWidth < 2) gradientWidth = 2;
	int gradientHeight = (viewMode) ? height() : height() / 2;

	QPainter painter(this);
	QVector<sRGB> grad = gradient.GetGradient(gradientWidth, false);

	for (int x = 0; x < grad.size(); x++)
	{
		QColor color(QColor(grad[x].R, grad[x].G, grad[x].B));
		painter.setPen(color);
		painter.drawLine(x + margins, 0, x + margins, gradientHeight);
	}

	if (!viewMode)
	{
		QList<cColorGradient::sColor> listOfColors = gradient.GetListOfColors();
		for (cColorGradient::sColor posColor : listOfColors)
		{
			PaintButton(posColor, painter);
		}
	}
}

int cGradientEditWidget::CalcButtonPosition(double position)
{
	return margins + position * (width() - 2 * margins - 1);
}

void cGradientEditWidget::PaintButton(const cColorGradient::sColor &posColor, QPainter &painter)
{
	int buttonPosition = CalcButtonPosition(posColor.position);

	int buttonTop = height() / 2 + buttonWidth / 2;

	QRect rect(QPoint(buttonPosition - buttonWidth / 2, buttonTop),
		QPoint(buttonPosition + buttonWidth / 2, height() - 2));

	QColor color(posColor.color.R, posColor.color.G, posColor.color.B);

	QBrush brush(color, Qt::SolidPattern);
	painter.fillRect(rect, brush);

	QVector<QPoint> triangle = {QPoint(buttonPosition, height() / 2),
		QPoint(buttonPosition - buttonWidth / 2, buttonTop),
		QPoint(buttonPosition + buttonWidth / 2, buttonTop)};
	QPolygon pTriangle(triangle);
	QPainterPath pathTriangle;
	pathTriangle.addPolygon(pTriangle);
	painter.fillPath(pathTriangle, brush);

	int avgColor = (posColor.color.R + posColor.color.G + posColor.color.B) / 3;
	if (avgColor > 100)
		painter.setPen(Qt::black);
	else
		painter.setPen(Qt::white);

	painter.drawRect(rect);
}

int cGradientEditWidget::FindButtonAtPosition(int x)
{
	QList<cColorGradient::sColor> listOfColors = gradient.GetListOfColors();

	for (int i = listOfColors.size() - 1; i >= 0; i--)
	{
		int xButton = CalcButtonPosition(listOfColors[i].position);
		if ((x > xButton - buttonWidth / 2) && (x <= xButton + buttonWidth / 2))
		{
			return i;
		}
	}
	return -1; //-1 means nothing found
}

void cGradientEditWidget::mouseMoveEvent(QMouseEvent *event)
{
	if (pressedColorIndex >= 2)
	{
		if (event->x() != dragStartX)
		{
			mouseDragStarted = true;
		}

		if (mouseDragStarted)
		{
			double pos = double(event->x() - margins) / (width() - 2 * margins - 1);
			gradient.ModifyPosition(pressedColorIndex, pos);
			emit update();
		}
	}
}

void cGradientEditWidget::mousePressEvent(QMouseEvent *event)
{
	if (event->button() == Qt::LeftButton)
	{
		if (viewMode)
		{
			emit openEditor();
		}
		else
		{
			int mouseX = event->x();
			int mouseY = event->y();

			if (mouseY > height() / 2)
			{
				int index = FindButtonAtPosition(mouseX);

				dragStartX = mouseX;
				pressedColorIndex = index;
			}
		}
	}
}

void cGradientEditWidget::mouseReleaseEvent(QMouseEvent *event)
{
	if (event->button() == Qt::LeftButton)
	{
		if (!viewMode)
		{
			if (pressedColorIndex >= 0 && !mouseDragStarted)
			{
				QList<cColorGradient::sColor> listOfColors = gradient.GetListOfColors();

				QColorDialog colorDialog(this);
				colorDialog.setOption(QColorDialog::DontUseNativeDialog);
				sRGB colorRGB = listOfColors[pressedColorIndex].color;
				QColor color(colorRGB.R, colorRGB.G, colorRGB.B);
				colorDialog.setCurrentColor(color);
				colorDialog.setWindowTitle(
					tr("Edit color #%1").arg(QString::number(pressedColorIndex + 1)));
				if (colorDialog.exec() == QDialog::Accepted)
				{
					color = colorDialog.currentColor();
					colorRGB = sRGB(color.red(), color.green(), color.blue());
					gradient.ModifyColor(pressedColorIndex, colorRGB);

					if (pressedColorIndex == 0) gradient.ModifyColor(1, colorRGB);

					if (pressedColorIndex == 1) gradient.ModifyColor(0, colorRGB);

					emit update();
				}
			}

			pressedColorIndex = -1;
			mouseDragStarted = false;
		}
	}
}

void cGradientEditWidget::SetColors(const QString &colorsString)
{
	gradient.SetColorsFromString(colorsString);
	emit update();
}

void cGradientEditWidget::AddColor(QContextMenuEvent *event)
{
	int xClick = event->x();
	int gradientWidth = width() - 2 * margins;
	double pos = double(xClick - margins) / gradientWidth;
	gradient.SortGradient();
	sRGB color = gradient.GetColor(pos, false);
	gradient.AddColor(color, pos);
	emit update();
}

void cGradientEditWidget::RemoveColor(QContextMenuEvent *event)
{
	int xClick = event->x();
	int index = FindButtonAtPosition(xClick);
	if (index >= 2)
	{
		gradient.RemoveColor(index);
	}
	emit update();
}

void cGradientEditWidget::Clear()
{
	gradient.DeleteAndKeepTwo();
	emit update();
}

void cGradientEditWidget::ChangeNumberOfColors()
{
	bool ok;
	int newNumber = QInputDialog::getInt(this, tr("Change number of colors"),
		tr("New number of colors:"), gradient.GetNumberOfColors() - 1, 1, 100, 1, &ok);
	if (ok && newNumber != gradient.GetNumberOfColors() - 1)
	{
		gradient.SortGradient();
		cColorGradient newGradient;
		newGradient.DeleteAll();
		double step = 1.0 / newNumber;
		for (int i = 0; i < newNumber; i++)
		{
			if (i == 0)
			{
				sRGB color = gradient.GetColor(0.0, false);
				newGradient.AddColor(color, 0.0);
				newGradient.AddColor(color, 1.0);
			}
			else
			{
				double pos = step * i;
				sRGB color = gradient.GetColor(pos, false);
				newGradient.AddColor(color, pos);
			}
		}
		gradient = newGradient;
	}
	emit update();
}

void cGradientEditWidget::GrabColors()
{
	PreviewFileDialog dialog(this);
	dialog.setFileMode(QFileDialog::ExistingFile);
	dialog.setNameFilter(tr("Images (*.jpg *.jpeg *.png *.bmp)"));
	dialog.setDirectory(QDir::toNativeSeparators(systemData.GetImagesFolder() + QDir::separator()));
	dialog.selectFile(QDir::toNativeSeparators(systemData.lastImagePaletteFile));
	dialog.setAcceptMode(QFileDialog::AcceptOpen);
	dialog.setWindowTitle(tr("Select image to grab colors..."));
	QStringList filenames;
	if (dialog.exec())
	{
		filenames = dialog.selectedFiles();
		QString filename = QDir::toNativeSeparators(filenames.first());

		QImage imagePalette(filename);

		if (!imagePalette.isNull())
		{
			int width = imagePalette.width();
			int height = imagePalette.height();
			int numberOfColors = gradient.GetNumberOfColors();
			gradient.DeleteAll();

			double step = 1.0 / numberOfColors;

			for (int i = 0; i < numberOfColors; i++)
			{
				double angle = double(i) / numberOfColors * M_PI * 2.0;
				double x = width / 2 + cos(angle) * width * 0.4;
				double y = height / 2 + sin(angle) * height * 0.4;
				QRgb pixel = imagePalette.pixel(x, y);
				sRGB pixelRGB(qRed(pixel), qGreen(pixel), qBlue(pixel));

				if (i == 0)
				{
					gradient.AddColor(pixelRGB, 0.0);
					gradient.AddColor(pixelRGB, 1.0);
				}
				else
				{
					double pos = step * i;
					gradient.AddColor(pixelRGB, pos);
				}
			}
		}

		systemData.lastImagePaletteFile = filename;
	}

	emit update();
}

void cGradientEditWidget::LoadColors()
{
	QFileDialog dialog(this);
	dialog.setOption(QFileDialog::DontUseNativeDialog);
	dialog.setFileMode(QFileDialog::AnyFile);
	dialog.setNameFilter(tr("Gradients (*.gradient *.txt)"));
	dialog.setDirectory(
		QDir::toNativeSeparators(QFileInfo(systemData.lastGradientFile).absolutePath()));
	dialog.selectFile(
		QDir::toNativeSeparators(QFileInfo(systemData.lastGradientFile).completeBaseName()));
	dialog.setAcceptMode(QFileDialog::AcceptOpen);
	dialog.setWindowTitle(tr("Load gradient..."));
	dialog.setDefaultSuffix("gradient");
	QStringList filenames;
	if (dialog.exec())
	{
		filenames = dialog.selectedFiles();
		QString filename = QDir::toNativeSeparators(filenames.first());
		systemData.lastGradientFile = filename;

		QFile file(filename);
		if (file.open(QIODevice::ReadOnly))
		{
			QString stringLoaded;
			QTextStream stream(&file);
			stringLoaded = stream.readLine();

			bool result = DecodeGradientFromFile(stringLoaded);
			if (!result)
			{
				cErrorMessage::showMessage(
					QObject::tr("Selected file doesn't contain valid gradient of colors"),
					cErrorMessage::errorMessage);
				return;
			}

			file.close();
		}
	}
}

bool cGradientEditWidget::DecodeGradientFromFile(QString string)
{
	QString header = "[gradient]";
	if (string.left(header.length()) == header)
	{
		QString gradientText = string.mid(header.length() + 1);
		gradient.SetColorsFromString(gradientText);
		return true;
	}
	return false;
}

void cGradientEditWidget::SaveColors()
{
	QFileDialog dialog(this);
	dialog.setOption(QFileDialog::DontUseNativeDialog);
	dialog.setFileMode(QFileDialog::AnyFile);
	dialog.setNameFilter(tr("Gradients (*.gradient *.txt)"));
	dialog.setDirectory(
		QDir::toNativeSeparators(QFileInfo(systemData.lastGradientFile).absolutePath()));
	dialog.selectFile(
		QDir::toNativeSeparators(QFileInfo(systemData.lastGradientFile).completeBaseName()));
	dialog.setAcceptMode(QFileDialog::AcceptSave);
	dialog.setWindowTitle(tr("Save gradient..."));
	dialog.setDefaultSuffix("gradient");
	QStringList filenames;
	if (dialog.exec())
	{
		filenames = dialog.selectedFiles();
		QString filename = QDir::toNativeSeparators(filenames.first());
		systemData.lastGradientFile = filename;

		QFile file(filename);
		if (file.open(QIODevice::ReadWrite))
		{
			QString string = gradient.GetColorsAsString();
			QTextStream stream(&file);
			stream << "[gradient] " << string << endl;
			file.close();
		}
	}
}

void cGradientEditWidget::LoadFromClipboard()
{
	QClipboard *clipboard = QApplication::clipboard();
	QString stringLoaded = clipboard->text();

	bool result = DecodeGradientFromFile(stringLoaded);
	if (!result)
	{
		cErrorMessage::showMessage(QObject::tr("Clipboard doesn't contain valid gradient of colors"),
			cErrorMessage::errorMessage);
		return;
	}
}

void cGradientEditWidget::SaveToClipboard()
{
	QClipboard *clipboard = QApplication::clipboard();
	QString string = QString("[gradient] ") + gradient.GetColorsAsString();
	clipboard->setText(string);
}

void cGradientEditWidget::contextMenuEvent(QContextMenuEvent *event)
{
	QMenu *menu = new QMenu();
	QAction *actionAddColor = menu->addAction(tr("Add color"));
	QAction *actionRemoveColor = menu->addAction(tr("Remove color"));
	menu->addSeparator();
	QAction *actionClear = menu->addAction(tr("Delete all colors"));
	QAction *actionChangeNumberOfColors = menu->addAction(tr("Change number of colors ..."));
	QAction *actionGrabColors = menu->addAction(tr("Grab colors from image ..."));
	QAction *actionLoad = menu->addAction(tr("Load colors from file ..."));
	QAction *actionSave = menu->addAction(tr("Save colors to file ..."));
	QAction *actionCopy = menu->addAction(tr("Copy"));
	QAction *actionPaste = menu->addAction(tr("Paste"));

	const QAction *selectedItem = menu->exec(event->globalPos());

	if (selectedItem)
	{
		if (selectedItem == actionAddColor) AddColor(event);
		if (selectedItem == actionRemoveColor) RemoveColor(event);
		if (selectedItem == actionClear) Clear();
		if (selectedItem == actionChangeNumberOfColors) ChangeNumberOfColors();
		if (selectedItem == actionGrabColors) GrabColors();
		if (selectedItem == actionLoad) LoadColors();
		if (selectedItem == actionSave) SaveColors();
		if (selectedItem == actionCopy) SaveToClipboard();
		if (selectedItem == actionPaste) LoadFromClipboard();
	}

	delete menu;
}