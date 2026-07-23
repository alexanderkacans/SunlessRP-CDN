if CLIENT then
    timer.Simple(math.random(120, 300), function()
        chat.AddText(
            Color(255, 215, 0), "Lord Tyler ",
            Color(255, 255, 255), "thanks you for using his addon, this message will be retired after ",
            Color(255, 80, 80), "May 4th",
            Color(255, 255, 255), ". ",
            Color(120, 180, 255), "May the force be with you, always."
        )
    end)
end