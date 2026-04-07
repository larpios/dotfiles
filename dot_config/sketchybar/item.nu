def geometry [
  --drawing = true # If the item should be drawn into the bar
  --position: string@'nu-complete position' #Position of the item in the bar
  --space: list<int> = [ 0 ] # Spaces to show this item on
  --display: list<int>|'activate' = [0] # Displays to show this item on (intergers or 'active')
  --ignore_association = false # Ignores all space / display associations while on
  --y_offset: int = 0 # Vertical offset applied to the item
  --padding_left: int = 0 # The padding applied left of the item
  --padding_right: int = 0 # The padding applied right of the item
  --width: int|'dynamic' = 'dynamic' # dynamic Makes the item use a fixed width given in points
  --scroll_texts = false # Controls the automatic scroll of all items texts, which are truncated by the max_chars property
  --blur_radius: int = 0 # The blur radius applied to the background of the item
  --background: record #   Items support all background properties
] {
  {
    drawing: $drawing
    position: $position
    space: $space
    display: $display
    ignore_association: $ignore_association
    y_offset: $y_offset
    padding_left: $padding_left
    padding_right: $padding_right
    width: $width
    scroll_texts: $scroll_texts
    blur_radius: $blur_radius
    background.<background_property>: $background.<background_property>
  }
}

def "nu-complete position" [] {
  [ 'left' 'right' 'center' ]
}
def "nu-complete display" [] {
  [ 'activate' ]
}
