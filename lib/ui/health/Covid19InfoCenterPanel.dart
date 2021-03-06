/*
 * Copyright 2020 Board of Trustees of the University of Illinois.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:illinois/model/Health.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/service/AppDateTime.dart';
import 'package:illinois/service/Config.dart';
import 'package:illinois/service/Health.dart';
import 'package:illinois/service/Localization.dart';
import 'package:illinois/service/NotificationService.dart';
import 'package:illinois/service/Styles.dart';
import 'package:illinois/ui/health/Covid19AddTestResultPanel.dart';
import 'package:illinois/ui/health/Covid19CareTeamPanel.dart';
import 'package:illinois/ui/health/Covid19GuidelinesPanel.dart';
import 'package:illinois/ui/health/Covid19StatusPanel.dart';
import 'package:illinois/ui/health/Covid19SymptomsPanel.dart';
import 'package:illinois/ui/health/Covid19TestLocations.dart';
import 'package:illinois/ui/health/Covid19HistoryPanel.dart';
import 'package:illinois/ui/health/Covid19WellnessCenter.dart';
//import 'package:illinois/ui/settings/SettingsNewHomePanel.dart';
import 'package:illinois/ui/settings/SettingsHomePanel.dart';
import 'package:illinois/ui/widgets/LinkTileButton.dart';
import 'package:illinois/ui/widgets/RibbonButton.dart';
import 'package:illinois/ui/widgets/RoundedButton.dart';
import 'package:illinois/ui/widgets/SectionTitlePrimary.dart';
import 'package:illinois/utils/Utils.dart';
import 'package:sprintf/sprintf.dart';

class Covid19InfoCenterPanel extends StatefulWidget {
  final Covid19Status status;

  Covid19InfoCenterPanel({Key key, this.status}) : super(key: key);

  @override
  _Covid19InfoCenterPanelState createState() => _Covid19InfoCenterPanelState();
}

class _Covid19InfoCenterPanelState extends State<Covid19InfoCenterPanel> implements NotificationsListener {

  Covid19Status _status;
  bool          _loadingStatus;
  Covid19History _lastHistory;

  @override
  void initState() {
    super.initState();
    NotificationService().subscribe(this, [
      Health.notifyStatusChanged,
      Health.notifyCountyStatusAvailable,
      Health.notifyUserUpdated,
      Health.notifyHistoryUpdated,
    ]);

    if (widget.status != null) {
      _status = widget.status;
    }
    else {
      _loadStatus();
    }

    _loadHistory();
  }

  @override
  void dispose() {
    super.dispose();
    NotificationService().unsubscribe(this);
  }

  @override
  void onNotification(String name, param) {
    if (name == Health.notifyStatusChanged) {
      _updateStatus(param);
    }
    else if (name == Health.notifyCountyStatusAvailable) {
      _updateStatus(param);
    }
    else if (name == Health.notifyUserUpdated) {
      if (_status?.blob == null) {
        _loadStatus();
      }
    } else if (name == Health.notifyHistoryUpdated) {
      _loadHistory();
    }
  }

  void _loadStatus() {
    setState(() {
      _loadingStatus = true;
    });
    Health().currentCountyStatus.then((Covid19Status status) {
      setState(() {
        _status = status;
        _loadingStatus = Health().processingCountyStatus;
      });
    });
  }

  void _updateStatus(Covid19Status status) {
    if (mounted) {
      setState(() {
        _status = status;
        _loadingStatus = false;
      });
    }
  }

  void _loadHistory(){
    Health().loadCovid19History().then((List<Covid19History> history) {
      if (mounted) {
       setState(() {
         _lastHistory = Covid19History.mostRecent(history);
       });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles().colors.background,
      appBar: _Covid19HomeHeaderBar(context: context,),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildNextStepPrimarySection(),
              _buildHealthPrimarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepPrimarySection() {
    return Health().isUserLoggedIn ? SectionTitlePrimary(
      title: Localization().getStringEx("panel.covid19home.top_heading.title", "Stay Healthy"),
      iconPath: 'images/icon-health.png',
      children: <Widget>[
        _buildMostRecentEvent(),
        Container(height: 10,),
        _buildNextStepSection(),
        Container(height: 10,),
        _buildSymptomCheckInSection(),
        Container(height: 10,),
        _buildAddTestResultSection(),
        Container(height: 20,),
      ],) : Container();
  }

  Widget _buildHealthPrimarySection() {
    bool isLoggedIn = Health().isUserLoggedIn;
    return SectionTitlePrimary(
      title: Localization().getStringEx("panel.covid19home.label.health.title","Your Health"),
      iconPath: 'images/icon-member.png',
      children: <Widget>[
        isLoggedIn ? _buildStatusSection() : Container(),
        isLoggedIn ? Container(height: 10,) : Container(),
        _buildTileButtons(),
        Container(height: 5,),
        isLoggedIn ? _buildViewHistoryButton() : _buildFindTestLocationsButton(),
        Container(height: 10,),
        _buildCovidWellnessCenter(),
      ]);

  }
  Widget _buildMostRecentEvent(){
    if(_lastHistory?.blob == null) {
      return Container();
    }
    String headingText = Localization().getStringEx("panel.covid19home.label.most_recent_event.title", "MOST RECENT EVENT");
    DateTime entryDate = _lastHistory.dateUtc;
    String dateText = (entryDate != null) ? AppDateTime().formatDateTime(entryDate, format:"MMMM dd, yyyy") : '';
    String historyTitle = "", info = "";
    Covid19HistoryBlob blob = _lastHistory.blob;
    if(blob.isTest){
      bool isManualTest = _lastHistory.isManualTest ?? false;
      historyTitle = blob?.testType ?? Localization().getStringEx("app.common.label.other", "Other");
      info = isManualTest? Localization().getStringEx("panel.covid19home.label.provider.self_reported", "Self reported"):
            (blob?.provider ?? Localization().getStringEx("app.common.label.other", "Other"));
    } else if(blob.isAction){
      historyTitle = Localization().getStringEx("panel.covid19home.label.action_required.title", "Action Required");
      info = blob.actionDisplayString?? "";
    } else if(blob.isContactTrace){
      historyTitle = Localization().getStringEx("panel.covid19home.label.contact_trace.title", "Contact Trace");
      info = blob.traceDurationDisplayString;
    } else if(blob.isSymptoms){
      historyTitle = Localization().getStringEx("panel.covid19home.label.reported_symptoms.title", "Self Reported Symptoms");
      info = blob.symptomsDisplayString;
    }

    return Semantics(container: true, child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Styles().colors.surface, borderRadius: BorderRadius.all(Radius.circular(4)), boxShadow: [BoxShadow(color: Styles().colors.blackTransparent018, spreadRadius: 2.0, blurRadius: 6.0, offset: Offset(2, 2))] ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Stack(children: <Widget>[
          Visibility(visible: (_loadingStatus != true),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Row(children: <Widget>[
                  Text(headingText, style: TextStyle(letterSpacing: 0.5, fontFamily: Styles().fontFamilies.bold, fontSize: 12, color: Styles().colors.fillColorPrimary),),
                  Expanded(child: Container(),),
                  Text(dateText, style: TextStyle(fontFamily: Styles().fontFamilies.regular, fontSize: 12, color: Styles().colors.textSurface),)
                ],),
                Container(height: 12,),
                Text(historyTitle, style: TextStyle(fontFamily: Styles().fontFamilies.extraBold, fontSize: 20, color: Styles().colors.fillColorPrimary),),
                info.isNotEmpty ? Container(height: 12,) : Container(),
                info.isNotEmpty ?
                  Text(info,style: TextStyle(fontFamily: Styles().fontFamilies.regular, fontSize: 16, color: Styles().colors.textSurface),)
                  : Container(),
              ],),
            ),
          ),
          Visibility(visible: (_loadingStatus == true),
            child: Container(
              height: 60,
              child: Align(alignment: Alignment.center,
                child: SizedBox(height: 24, width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Styles().colors.fillColorSecondary), )
                ),
              ),
            ),
          ),
        ],),

        Container(margin: EdgeInsets.only(top: 14, bottom: 14), height: 1, color: Styles().colors.fillColorPrimaryTransparent015,),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(explicitChildNodes: true, child: RoundedButton(
            label: Localization().getStringEx("panel.covid19home.button.view_history.title", "View Health History"),
            hint: Localization().getStringEx("panel.covid19home.button.view_history.hint", ""),
            borderColor: Styles().colors.fillColorSecondary,
            backgroundColor: Styles().colors.surface,
            textColor: Styles().colors.fillColorPrimary,
            onTap: _onTapTestHistory,
          )),
        )
      ],),
    ));
  }

  Widget _buildNextStepSection() {
    String headingText = (_status?.blob?.nextStep != null) ? Localization().getStringEx("panel.covid19home.label.next_step.title", "NEXT STEP") : '';
    String nextStepTitle = _status?.blob?.displayNextStep ?? '';
    String headingDate = (_status?.blob?.nextStepDateUtc != null) ? AppDateTime().formatDateTime(_status.blob.nextStepDateUtc.toLocal(), format:"MMMM dd, yyyy") : '';
    String scheduleText = (_status?.blob?.nextStepDateUtc != null) ? sprintf(Localization().getStringEx("panel.covid19home.label.schedule_after.title", "Schedule after %s"), [AppDateTime().formatDateTime(_status.blob.nextStepDateUtc.toLocal(), format:"MMMM dd")]) : '';

    return Semantics(container: true, child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Styles().colors.surface, borderRadius: BorderRadius.all(Radius.circular(4)), boxShadow: [BoxShadow(color: Styles().colors.blackTransparent018, spreadRadius: 2.0, blurRadius: 6.0, offset: Offset(2, 2))] ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Stack(children: <Widget>[
          Visibility(visible: (_loadingStatus != true),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Row(children: <Widget>[
                  Text(headingText, style: TextStyle(letterSpacing: 0.5, fontFamily: Styles().fontFamilies.bold, fontSize: 12, color: Styles().colors.fillColorPrimary),),
                  Expanded(child: Container(),),
                  Text(headingDate, style: TextStyle(fontFamily: Styles().fontFamilies.regular, fontSize: 12, color: Styles().colors.textSurface),)
                ],),
                Container(height: 12,),
                Text(nextStepTitle, style: TextStyle(fontFamily: Styles().fontFamilies.extraBold, fontSize: 20, color: Styles().colors.fillColorPrimary),),
                scheduleText.isNotEmpty ? Container(height: 12,) : Container(),
                scheduleText.isNotEmpty ? Row(children: <Widget>[
                    Visibility(visible: scheduleText.isNotEmpty, child: Padding(padding: EdgeInsets.only(right: 8), child: Image.asset('images/icon-calendar.png', excludeFromSemantics: true, ),),),
                    Text(scheduleText,style: TextStyle(fontFamily: Styles().fontFamilies.regular, fontSize: 16, color: Styles().colors.textSurface),),
                ],) : Container(),
              ],),
            ),
          ),
          Visibility(visible: (_loadingStatus == true),
            child: Container(
              height: 60,
              child: Align(alignment: Alignment.center,
                child: SizedBox(height: 24, width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Styles().colors.fillColorSecondary), )
                ),
              ),
            ),
          ),
        ],),
        
        Container(margin: EdgeInsets.only(top: 14, bottom: 14), height: 1, color: Styles().colors.fillColorPrimaryTransparent015,),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(explicitChildNodes: true, child: RoundedButton(
            label: Localization().getStringEx("panel.covid19home.button.find_test_locations.title", "Find test locations"),
            hint: Localization().getStringEx("panel.covid19home.button.find_test_locations.hint", ""),
            borderColor: Styles().colors.fillColorSecondary,
            backgroundColor: Styles().colors.surface,
            textColor: Styles().colors.fillColorPrimary,
            onTap: ()=> _onTapFindLocations(),
          )),
        )
      ],),
    ));
  }

  Widget _buildSymptomCheckInSection() {
    String title = Localization().getStringEx("panel.covid19home.label.check_in.title","Symptom Check-in");
    String description = Localization().getStringEx("panel.covid19home.label.check_in.description","Self-report any symptoms to see if you should get tested or stay home");
    return Semantics(container: true, child: 
      InkWell(onTap: _onTapSymptomCheckIn, child:
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16
          ),
          decoration: BoxDecoration(color: Styles().colors.surface, borderRadius: BorderRadius.all(Radius.circular(4)), boxShadow: [BoxShadow(color: Styles().colors.blackTransparent018, spreadRadius: 2.0, blurRadius: 6.0, offset: Offset(2, 2))] ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Row(children: <Widget>[
              Expanded(child:
                Text(title, style: TextStyle(fontFamily: Styles().fontFamilies.extraBold, fontSize: 20, color: Styles().colors.fillColorPrimary),),
              ),
              Image.asset('images/chevron-right.png'),
            ],),
            Padding(padding: EdgeInsets.only(top: 5), child:
              Text(description, style: TextStyle(fontFamily: Styles().fontFamilies.regular, fontSize: 16, color: Styles().colors.textSurface),),
            ),
          ],),),),
      );
  }

  Widget _buildAddTestResultSection() {
    String title = Localization().getStringEx("panel.covid19home.label.result.title","Add Test Result");
    String description = Localization().getStringEx("panel.covid19home.label.result.description","To keep your status up-to-date");
    return Semantics(container: true, child: 
      InkWell(onTap: () => _onTapReportTest(), child:
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16
          ),
          decoration: BoxDecoration(color: Styles().colors.surface, borderRadius: BorderRadius.all(Radius.circular(4)), boxShadow: [BoxShadow(color: Styles().colors.blackTransparent018, spreadRadius: 2.0, blurRadius: 6.0, offset: Offset(2, 2))] ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Row(children: <Widget>[
              Expanded(child:
                Text(title, style: TextStyle(fontFamily: Styles().fontFamilies.extraBold, fontSize: 20, color: Styles().colors.fillColorPrimary),),
              ),
              Image.asset('images/chevron-right.png'),
            ],),
            Padding(padding: EdgeInsets.only(top: 5), child:
              Text(description, style: TextStyle(fontFamily: Styles().fontFamilies.regular, fontSize: 16, color: Styles().colors.textSurface),),
            ),
          ],),),),
      );
  }

  Widget _buildStatusSection() {
    String statusName = _status?.blob?.localizedHealthStatus;
    Color statusColor = covid19HealthStatusColor(_status?.blob?.healthStatus) ?? Styles().colors.textSurface;
    bool hasStatusCard  = Health().isUserLoggedIn;
    return Semantics(container: true, child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Styles().colors.surface, borderRadius: BorderRadius.all(Radius.circular(4)), boxShadow: [BoxShadow(color: Styles().colors.blackTransparent018, spreadRadius: 2.0, blurRadius: 6.0, offset: Offset(2, 2))] ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Stack(children: <Widget>[
          Visibility(visible: (_loadingStatus != true),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Row(children: <Widget>[
                  Expanded(child:
                    Text(Localization().getStringEx("panel.covid19home.label.status.title","Current Status:"), style: TextStyle(fontFamily: Styles().fontFamilies.bold, fontSize: 16, color: Styles().colors.fillColorPrimary),),
                  ),
                ],),
                Container(height: 6,),
                Row(
                  children: <Widget>[
                    Visibility(visible:AppString.isStringNotEmpty(statusName), child: Image.asset('images/icon-member.png', color: statusColor,),),
                    Visibility(visible:AppString.isStringNotEmpty(statusName), child: Container(width: 4,),),
                    Expanded(child:
                      Text(AppString.isStringNotEmpty(statusName) ? statusName : Localization().getStringEx('panel.covid19home.label.status.na', 'Not Available'), style: TextStyle(fontFamily: Styles().fontFamilies.medium, fontSize: 16, color: Styles().colors.textSurface),),
                    )
                  ],
                )
              ],),
            ),
          ),
          Visibility(visible: (_loadingStatus == true),
            child: Container(
              height: 16,
              child: Align(alignment: Alignment.center,
                child: SizedBox(height: 16, width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Styles().colors.fillColorSecondary), )
                ),
              ),
            ),
          ),
          Container(height: 16,),
        ],),

        hasStatusCard
            ? Container(margin: EdgeInsets.only(top: 14, bottom: 14), height: 1, color: Styles().colors.fillColorPrimaryTransparent015,)
            : Container(),

        hasStatusCard
          ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Semantics(explicitChildNodes: true, child: RoundedButton(
              label: Localization().getStringEx("panel.covid19home.button.show_status_card.title","Show Status Card"),
              hint: '',
              borderColor: Styles().colors.fillColorSecondary,
              backgroundColor: Styles().colors.surface,
              textColor: Styles().colors.fillColorPrimary,
              onTap: ()=> _onTapShowStatusCard(),
            )),
          )
            : Container()
      ],),
    ));
  }

  Widget _buildTileButtons(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: LinkTileSmallButton(
                width: double.infinity,
                iconPath: 'images/icon-country-guidelines.png',
                label: Localization().getStringEx("panel.covid19home.button.country_guidelines.title", "County\nGuidelines"),
                hint: Localization().getStringEx("panel.covid19home.button.country_guidelines.hint", ""),
                onTap: ()=>_onTapCountryGuidelines(),
              ),
            ),
            Container(width: 8,),
            Expanded(
              child: LinkTileSmallButton(
                width: double.infinity,
                iconPath: 'images/icon-your-care-team.png',
                label: Localization().getStringEx( "panel.covid19home.button.care_team.title", "Your\nCare Team"),
                hint: Localization().getStringEx( "panel.covid19home.button.care_team.hint", ""),
                onTap: () => _onTapCareTeam(),
              ),
            ),
          ],
        ),
        Container(height: 8,),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: LinkTileSmallButton(
                width: double.infinity,
                iconPath: 'images/icon-report-test.png',
                label: Localization().getStringEx("panel.covid19home.button.report_test.title", "Report a Test Result"),
                hint: Localization().getStringEx("panel.covid19home.button.report_test.hint", ""),
                onTap: ()=> _onTapReportTest(),
              ),
            ),
            Container(width: 8,),
            Expanded(
              child: LinkTileSmallButton(
                width: double.infinity,
                iconPath: 'images/icon-test-history.png',
                label: Localization().getStringEx("panel.covid19home.button.test_history.title", "Your Testing History"),
                hint: Localization().getStringEx("panel.covid19home.button.test_history.hint", ""),
                onTap: ()=>_onTapTestHistory(),
              ),
            ),
          ],
        )*/
      ],
    );
  }

  Widget _buildViewHistoryButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Color.fromRGBO(19, 41, 75, 0.3), spreadRadius: 2.0, blurRadius: 8.0, offset: Offset(0, 2))],
      ),
      child: RibbonButton(
        label: Localization().getStringEx("panel.covid19.button.health_history.title", "View Health History"),
        borderRadius: BorderRadius.circular(4),
        onTap: ()=>_onTapTestHistory(),
      ),
    );
  }

  Widget _buildCovidWellnessCenter() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Color.fromRGBO(19, 41, 75, 0.3), spreadRadius: 2.0, blurRadius: 8.0, offset: Offset(0, 2))],
      ),
      child: RibbonButton(
        label: Localization().getStringEx("panel.covid19.button.covid_wellness_center.title", "COVID-19 Wellness Answer Center"),
        borderRadius: BorderRadius.circular(4),
        onTap: ()=>_onTapCovidWellnessCenter(),
      ),
    );
  }

  Widget _buildFindTestLocationsButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Color.fromRGBO(19, 41, 75, 0.3), spreadRadius: 2.0, blurRadius: 8.0, offset: Offset(0, 2))],
      ),
      child: RibbonButton(
        label: Localization().getStringEx("panel.covid19home.button.find_test_locations.title", "Find test locations"),
        hint: Localization().getStringEx("panel.covid19home.button.find_test_locations.hint", ""),
        borderRadius: BorderRadius.circular(4),
        onTap: ()=>_onTapFindLocations(),
      ),
    );
  }
  

  /*Widget _buildCampusUpdatesSection() {
    String title = Localization().getStringEx("panel.covid19home.label.campus_updates.title","Campus Updates");
    return Semantics(container: true, child:
      InkWell(onTap: () => _onTapCampusUpdates(), child:
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16
          ),
          decoration: BoxDecoration(color: Styles().colors.surface, borderRadius: BorderRadius.all(Radius.circular(4)), boxShadow: [BoxShadow(color: Styles().colors.blackTransparent018, spreadRadius: 2.0, blurRadius: 6.0, offset: Offset(2, 2))] ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Row(children: <Widget>[
              Expanded(child:
                Text(title, style: TextStyle(fontFamily: Styles().fontFamilies.extraBold, fontSize: 20, color: Styles().colors.fillColorPrimary),),
              ),
              Image.asset('images/chevron-right.png'),
            ],),
          ],),),),
      );
  }*/

  /*Widget _buildAboutButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Color.fromRGBO(19, 41, 75, 0.3), spreadRadius: 2.0, blurRadius: 8.0, offset: Offset(0, 2))],
      ),
      child: RibbonButton(
        label: Localization().getStringEx("panel.covid19home.button.about.title","About"),
        borderRadius: BorderRadius.circular(4),
        onTap: ()=>_onTapAbout(),
      ),
    );
  }*/

  void _onTapCountryGuidelines() {
    Analytics.instance.logSelect(target: "COVID-19 County Guidlines");
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Covid19GuidelinesPanel(status: _status)));
  }

  /*void _onTapCampusUpdates() {
    Analytics.instance.logSelect(target: "COVID-19 Campus Updates");
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Covid19UpdatesPanel()));
  }*/

  void _onTapCareTeam() {
    Analytics.instance.logSelect(target: "Your Care Team");
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Covid19CareTeamPanel(status: _status,)));
  }

  void _onTapReportTest(){
    Analytics.instance.logSelect(target: "COVID-19 Report Test");
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>Covid19AddTestResultPanel()));
  }

  void _onTapTestHistory(){
    Analytics.instance.logSelect(target: "COVID-19 Test History");
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>Covid19HistoryPanel()));
  }

  void _onTapFindLocations(){
    Analytics.instance.logSelect(target: "COVID-19 Find Test Locations");
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>Covid19TestLocationsPanel()));
  }

  void _onTapShowStatusCard(){
    Analytics.instance.logSelect(target: "Show Status Card");
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Covid19StatusPanel()));
  }

  void _onTapSymptomCheckIn() {
    Analytics.instance.logSelect(target: "Symptom Check-in");
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>Covid19SymptomsPanel()));
  }

  void _onTapCovidWellnessCenter(){
    Analytics.instance.logSelect(target: "Wellness Center");
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>Covid19WellnessCenter()));
  }

  /*void _onTapAbout() {
    Analytics.instance.logSelect(target: "About");
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>Covid19AboutPanel()));
  }*/
}

class _Covid19HomeHeaderBar extends AppBar {
  final BuildContext context;
  final Widget titleWidget;
  final bool searchVisible;
  final bool rightButtonVisible;
  final String rightButtonText;
  final GestureTapCallback onRightButtonTap;

  static Color get _titleColor =>
      Config().configEnvironment == ConfigEnvironment.dev
          ? Colors.yellow : Config().configEnvironment == ConfigEnvironment.test ? Colors.green
          : Colors.white;

  _Covid19HomeHeaderBar({@required this.context, this.titleWidget, this.searchVisible = false,
    this.rightButtonVisible = false, this.rightButtonText, this.onRightButtonTap})
      : super(
      backgroundColor: Styles().colors.fillColorPrimaryVariant,
      title: Text(Localization().getStringEx("panel.covid19home.header.title", "Safer Illinois Home"),
        style: TextStyle(color: _titleColor, fontSize: 16, fontFamily: Styles().fontFamilies.extraBold),
      ),
      actions: <Widget>[
        Semantics(
            label: Localization().getStringEx('headerbar.settings.title', 'Settings'),
            hint: Localization().getStringEx('headerbar.settings.hint', ''),
            button: true,
            excludeSemantics: true,
            child: IconButton(
                icon: Image.asset('images/settings-white.png'),
                onPressed: () {
                  Analytics.instance.logSelect(target: "Settings");
                  //TMP: Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingsNewHomePanel()));
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingsHomePanel()));
                }))
      ],
      centerTitle: true);
}