using Genie, Genie.Router, Genie.Renderer.Html, Genie.Requests, Statistics, Formatting

# Taken from https://www.mybenefits.myflorida.com/financial_future/frs_pension_plan 
MEMBERCLASSDICT = Dict("Regular" => 0.016, "SeniorManagementService" => 0.02, "Judical" => 0.033, "OtherOffical" => 0.03, "SpecialRisk" => 0.003, "SpecialRiskAdmin" => 0.016)
form = """
<title>My Florida Pension Estimate</title>
<style>
body {
  font-family: "Helvetica Neue", "Arial", sans-serif;
  line-height: 200%;
}
</style>
<h1>My Florida Pension Estimate</h1>
<p>Welcome!</p>
<p>This website's purpose is to provide users with an <em>estimate</em> of what their pension might be under the Florida Retirement System (<em>FRS</em>) before they are vested. 
This is meant as an illustrative educational tool.
This website is not affiliated with the State of Florida nor the FRS.</p>
<p>The only required fields are:
<ol>
  <li>Your first fiscal year's highest compensation - at least one fiscal year is needed to calculate your FRS pension estimate.</li>
  <li>Your membership class - presently, the FRS does not offer pensions to Other Personal Services (<em>OPS</em>) employees and the formula differs for each of the other membership classes.</li>
  <li>Your total number of the years under the State of Florida employment (excluding OPS) - while up to the highest eight fiscal years are used, your total number of years under State of Florida employment (excluding OPS), which is also used, may be different.</li>
</ol> 
</p>
<p>
By using this website, you acknowledge:
<ul>
  <li>All information you provide is not stored in in any way whatsoever. 
  After your estimate is calculated, all your information is forgotten.
  This website's source code is <a href = "https://github.com/madisonestabrook/MyFLPensionEstimate"> publicly available on GitHub </a>.</li>
  <li>You understand and agree that this website is an illustrative educational tool and will not hold this website liable.</li>
</ul>
</p>
<h2>My Florida Pension Estimate Calculator</h2>
<form action="/" method="POST" enctype="multipart/form-data">
  <label for="year1">First highest fiscal year's compensation</label>
  <input type="number" name="year1" value="", min="0.01" step="0.01", placeholder="50000.00" required/>
  <br>  
  <label for="year2">Second highest fiscal year's compensation</label>
  <input type="number" name="year2" value="", min="0.01" step="0.01", placeholder="50000.00" /> 
  <br>
  <label for="year3">Third highest fiscal year's compensation</label>
  <input type="number" name="year3" value="", min="0.01" step="0.01", placeholder="50000.00" />
  <br>
  <label for="year4">Fourth highest fiscal year's compensation</label>
  <input type="number" name="year4" value="", min="0.01" step="0.01", placeholder="50000.00" />
  <br>
  <label for="year5">Fifth highest fiscal year's compensation</label>
  <input type="number" name="year5" value="", min="0.01" step="0.01", placeholder="50000.00" />
  <br>
  <label for="year6">Sixith highest fiscal year's compensation</label>
  <input type="number" name="year6" value="", min="0.01" step="0.01", placeholder="50000.00" />
  <br>
  <label for="year7">Seventh highest fiscal year's compensation</label>
  <input type="number" name="year7" value="", min="0.01" step="0.01", placeholder="50000.00" />
  <br>
  <label for="year8">Eighth highest fiscal year's compensation</label>
  <input type="number" name="year8" value="", min="0.01" step="0.01", placeholder="50000.00" />
  <br>
  <label for="MembershipClass">Membership Class:</label>
  <br>
  <input type="radio" id="MembershipClass" name="MembershipClass" value="Regular" required>
  <label for="MembershipClass">Regular</label>
  <br>
  <input type="radio" id="SeniorManagementService" name="MembershipClass" value="SeniorManagementService" required>
  <label for="SeniorManagementService">Senior Management Service</label>
  <br>
  <input type="radio" id="Judical" name="MembershipClass" value="Judical" required>
  <label for="Judical">Supreme Court Justice, District Court of Appeals Judge, Circuit Court Judge, or County Court Judge</label>
  <br>
  <input type="radio" id="OtherOffical" name="MembershipClass" value="OtherOffical" required>
  <label for="OtherOffical">Other Eligible Elected Officials</label>
  <br> 
  <input type="radio" id="SpecialRisk" name="MembershipClass" value="SpecialRisk" required>
  <label for="SpecialRisk">Special Risk (on and after 10/01/1974)</label>
  <br>
  <input type="radio" id="SpecialRiskAdmin" name="MembershipClass" value="SpecialRiskAdmin" required>
  <label for="SpecialRiskAdmin">Special Risk Administrative Support</label>
  <br>
  <label for="numYears">Estimated total number of years under State of Florida employment (excluding OPS)</label>
  <input type="number" name="numYears" value="", min="8" max="100" step="1", placeholder="8" required />
  <br>
  <input type="submit" value="Submit" />
</form>
"""

route("/") do
  html(form) # Display the form for the user
end

route("/", method = POST) do
    yearlyCompAmts = [postpayload(:year1), postpayload(:year2), postpayload(:year3), postpayload(:year4), postpayload(:year5), postpayload(:year6), postpayload(:year7), postpayload(:year8)] # Getting each year's compensation amounts
    yearlyCompAmts = replace(tryparse.(Float64, yearlyCompAmts), nothing  => missing) # Try to parse into Float64; if failure, set to `missing`
    numberOfServiceYears = parse(Int64, postpayload(:numYears))
    userMemberClassCode = postpayload(:MembershipClass) # Getting the user's membership class code
    userMemberClassValue = MEMBERCLASSDICT[userMemberClassCode] # code => value
    averageComp = mean(skipmissing(yearlyCompAmts)) # Getting the average compensation, exculding any missing years
    yearlyBenefit = (numberOfServiceYears * userMemberClassValue * averageComp)
    monthlyBenefit = yearlyBenefit / 12 # 12 months in a year
    yearlyBenefit = format(yearlyBenefit, commas=true, precision=2) # Make the estimated yearly benefit more user-friendly
    monthlyBenefit = format(monthlyBenefit, commas=true, precision=2) # Make the estimated monthly benefit more user-friendly
    futureServiceYears = numberOfServiceYears + 5 # Providing the user with a what if they worked an additional five years
    futureYearlyBenefit = (futureServiceYears * userMemberClassValue * averageComp)
    futureMonthlyBenefit = futureYearlyBenefit / 12 # 12 months in a year
    futureYearlyBenefit = format(futureYearlyBenefit, commas=true, precision=2) # Make the estimated future yearly benefit more user-friendly
    futureMonthlyBenefit = format(futureMonthlyBenefit, commas=true, precision=2) # Make the estimated future monthly benefit more user-friendly
    html("""
    <title>My Florida Pension Estimate</title>
    <style>
    body {
      font-family: "Helvetica Neue", "Arial", sans-serif;
      line-height: 200%;
    }
    </style>
    <h1>My Florida Pension Estimate</h1>
    <h2>Current Estimate</h2>
    <p>
    Your yearly benefit, based on $numberOfServiceYears years of State of Florida employment (excluding OPS), is estimated to be <strong>$yearlyBenefit</strong>, which is approximately $monthlyBenefit per month. 
    </p>
    <h2>Future Estimate</h2>
    <p>
    However, if you worked for the State of Florida for an <em>additional five years (excluding OPS)</em>, for a total of $futureServiceYears years of State of Florida employment (excluding OPS), assuming everything else stays the same, your yearly benefit might be <strong>$futureYearlyBenefit</strong>, which is approximately $futureMonthlyBenefit per month. 
    </p>
    """)
end

up()