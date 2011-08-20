#include "levelgraphicsview.h"

LevelGraphicsView::LevelGraphicsView(QWidget* pQW_Parent)
{
}

void LevelGraphicsView::mousePressEvent(QMouseEvent *event)
{
    // This is the default, it might get overwritten later in this function.
    resizing = false;

    // Check if control key is being held down
    bool controlDown = (event->modifiers() & Qt::ControlModifier);

    // Get item that was selected (if any)
    QGraphicsItem *item = itemAt(event->pos());

    if(controlDown)
    {
        // If something was selected
        if(item)
        {
            // If item is already selected, unselect it
            bool itemRemoved = false;
            if(selectedObjects->contains(item->data(2).toInt()))
            {
                selectedObjects->removeOne(item->data(2).toInt());
                itemRemoved = true;
            }

            // If item is new, add it
            else if(!selectedObjects->contains(item->data(2).toInt()))
            {
                selectedObjects->append(item->data(2).toInt());
            }

            // If we didn't just remove something, check for resizing
            if(!itemRemoved)
            {
                // Figure out if we are in resizing mode
                int mouseX = item->pos().x() - mapToScene(event->pos()).x();
                int mouseY = item->pos().y() - mapToScene(event->pos()).y();
                double rightPercent = (double)mouseX / item->boundingRect().size().width() * -1;
                double bottomPercent = (double)mouseY / item->boundingRect().size().height() * -1;

                if(!(item->data(3).toBool()) && (rightPercent >= .9 || bottomPercent >= .9))
                {
                    resizing = true;
                }
            }
        }
    }
    else // Control not being held down
    {
        // If something was selected
        if(item)
        {
            // If item is new, clear and add it
            if(!selectedObjects->contains(item->data(2).toInt()))
            {
                selectedObjects->clear();
                selectedObjects->append(item->data(2).toInt());
            }

            // Check for resizing
            // Figure out if we are in resizing mode
            int mouseX = item->pos().x() - mapToScene(event->pos()).x();
            int mouseY = item->pos().y() - mapToScene(event->pos()).y();
            double rightPercent = (double)mouseX / item->boundingRect().size().width() * -1;
            double bottomPercent = (double)mouseY / item->boundingRect().size().height() * -1;

            if(!(item->data(3).toBool()) && (rightPercent >= .9 || bottomPercent >= .9))
            {
                resizing = true;
            }
        }
        else // nothing selected
        {
            selectedObjects->clear();
        }
    }

    // Fill up list of start positions (for use in mouseMove and moveReleased)
    objectStartPositions.clear();
    for(int i = 0; i < selectedObjects->length(); i++)
    {
        objectStartPositions.append(getItemForId(selectedObjects->at(i))->pos());
    }

    // Save where we first clicked the mouse (for use in mouseMoveEvent and mouseReleaseEvent)
    mouseDownPoint = mapToScene(event->pos());

    emit needToUpdateGraphics();
}

void LevelGraphicsView::mouseMoveEvent(QMouseEvent *event)
{
    if(selectedObjects->length() == 0) // no item selected
    {
        return;
    }

    QPointF currentMousePos = mapToScene(event->pos());

    for(int i = 0; i < selectedObjects->length(); i++)
    {
        QGraphicsItem* draggedItem = getItemForId(selectedObjects->at(i));

        if(!resizing)
        {
            QPointF pos = currentMousePos - mouseDownPoint + objectStartPositions[i];
            draggedItem->setPos(pos);
            emit objectChanged(draggedItem->data(1).toString(), draggedItem->data(2).toInt(), pos, draggedItem->boundingRect().size(), true);
        }
        else
        {
            QPointF newPoint = mapToScene(event->pos());

            double scaleX = 1; //(newPoint.x() - draggedItem->pos().x()) / (previousPoint.x() - draggedItem->pos().x());
            double scaleY = 1; //(newPoint.y() - draggedItem->pos().y()) / (previousPoint.y() - draggedItem->pos().y());

            if(scaleX > 0 && scaleY > 0)
            {
                //previousPoint = newPoint;
                emit needToRescale(draggedItem->data(1).toString(), draggedItem->data(2).toInt(), scaleX, scaleY, true);
            }
        }
    }
}

void LevelGraphicsView::mouseReleaseEvent(QMouseEvent *event)
{
    if(selectedObjects->length() == 0) // no item selected
    {
        //mouseDownPoint = QPointF(0,0);
        return;
    }

    QPointF currentMousePos = mapToScene(event->pos());

    for(int i = 0; i < selectedObjects->length(); i++)
    {
        QGraphicsItem* draggedItem = getItemForId(selectedObjects->at(i));

        if(!resizing)
        {
            QPointF pos = currentMousePos - mouseDownPoint + objectStartPositions[i];
            draggedItem->setPos(pos);
            emit objectChanged(draggedItem->data(1).toString(), draggedItem->data(2).toInt(), pos, draggedItem->boundingRect().size(), false);
        }
        else
        {
            QPointF newPoint = mapToScene(event->pos());

            double scaleX = 1; //(newPoint.x() - draggedItem->pos().x()) / (previousPoint.x() - draggedItem->pos().x());
            double scaleY = 1; //(newPoint.y() - draggedItem->pos().y()) / (previousPoint.y() - draggedItem->pos().y());

            if(scaleX > 0 && scaleY > 0)
            {
                //previousPoint = newPoint;
                emit needToRescale(draggedItem->data(1).toString(), draggedItem->data(2).toInt(), scaleX, scaleY, false);
            }
        }
    }

    resizing = false;
    //mouseDownPoint = QPointF(0,0);
}

QGraphicsItem* LevelGraphicsView::getItemForId(int id)
{
    QList<QGraphicsItem*> its = items();
    for(int i = 0; i < its.count(); i++)
    {
        if (its[i]->data(2).toInt() == id && its[i]->data(1).toString() != "")
        {
            return its[i];
        }
    }

    return NULL;
}

void LevelGraphicsView::setListPointer(QList<int> *pointer)
{
    selectedObjects = pointer;

    // Make sure we get keyboard input
    setFocusPolicy(Qt::StrongFocus);

    qDebug("Constructing");
}
