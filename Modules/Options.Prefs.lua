return {
    SmartJudgments =
	{
		UserPref = true,
		OneInRow = true,
		Default = THEME:GetMetric("Common","DefaultJudgment"),
		Choices = LoadModule("Options.SmartJudgeChoices.lua")(),
		Values = LoadModule("Options.SmartJudgeChoices.lua")("Value")
	},
	SmartTimings =
	{
		GenForOther = {"SmartJudgments",LoadModule("Options.SmartJudgeChoices.lua")},
		GenForUserPref = true,
		Default = TimingModes[1],
		Choices = TimingModes,
		Values = TimingModes
	},
}