# The scene editor

## Moving around the 3D view

| Do | Mouse | Laptop |
|---|---|---|
| Orbit | middle-drag | Alt + left-drag |
| Pan | Shift + middle-drag | Alt + Shift + left-drag |
| Zoom | wheel | wheel / two fingers |
| Look around | right-drag; while held, W A S D move, Q E go down/up, Shift faster | |

F frames the selection, Home everything. Numpad 7 / 1 / 3 look from above, the front and the right; Numpad 5 switches perspective and orthographic; Numpad 0 looks through the selected camera.

## Selecting

Click an object. Ctrl+click adds or removes. Drag on empty space to select everything inside a box. Esc selects nothing. A click on a model selects the whole model, and a click on an LED wall selects the wall, not one of its parts. Cameras, lights and empty groups show as markers you can click.

## Moving, turning, resizing

Q select, W move, E turn, R resize. Drag an arrow to move along it, a coloured square to move in its plane, the centre to move with the screen; drag a ring to turn; drag a box to resize along an axis or the centre box to resize evenly. Hold Ctrl to snap (half metres, 15°, tenths); Y keeps snapping on. T lines the handles up with the object instead of the world. Esc or a right click during a drag puts it back. A whole drag is one undo step.

## The scene tree

Every object you placed, in groups as you arranged them, each with an icon for its kind (a building, a tree, a person, a light, a camera...). The insides of imported models and Oriel set pieces are not listed; they are edited as one object. The eye at the end of a row shows or hides the object; the padlock locks it, so a click in the 3D view goes through it. *Search by name* narrows the list; the number at the top is how many objects there are. Double-click (or F2) renames. Drag to reorder or to put one object inside another (it stays where it is in the world). Right-click: duplicate, delete, group, ungroup, show/hide, lock, frame.

## Properties

At the top, the selected object's name and what kind of thing it is. Then, in sections that fold (a folded section stays folded from one object to the next): its place, turn and size; a light's colour, brightness and reach; a camera's lens; every setting of a Oriel set piece (LED wall cabinets, truss length, crowd density...); and *About*: which library it is from, the file it was brought in from (the folder button shows it in the file manager) and the licence of a library model. Changes are undoable; dragging a value is one step.

## Adding

Add > Empty Group, Box, Plane, Sphere, Cylinder, Point light, Spot light, Camera From This View. New objects appear where the view is looking, selected.

## Undo

Ctrl+Z / Ctrl+Shift+Z (or Ctrl+Y). The Edit menu names the step ("Undo: Move Pavilion").
