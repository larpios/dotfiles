alias lso = ls

export def main [...args] {
  ls ...$args | table -o -t with_love
}
