json.array! @phases do |phase|
  json.partial! 'phase', phase: phase
end
