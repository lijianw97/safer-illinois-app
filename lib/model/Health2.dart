
import 'package:illinois/model/Health.dart';
import 'package:illinois/service/AppDateTime.dart';

///////////////////////////////
// HealthTestRulesSet2

class HealthTestRulesSet2 {
  final List<HealthTestRule2> rules;
  final Map<String, _HealthRuleStatus2> statuses;

  HealthTestRulesSet2({this.rules, this.statuses});

  factory HealthTestRulesSet2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthTestRulesSet2(
      rules: HealthTestRule2.listFromJson(json['rules']),
      statuses: _HealthRuleStatus2.mapFromJson(json['statuses']),
    ) : null;
  }

  HealthTestRuleResult2 matchRuleResult({ Covid19HistoryBlob blob }) {
    if ((rules != null) && (blob != null)) {
      for (HealthTestRule2 rule in rules) {
        if ((rule?.testType != null) && (rule?.testType?.toLowerCase() == blob?.testType?.toLowerCase()) && (rule.results != null)) {
          for (HealthTestRuleResult2 ruleResult in rule.results) {
            if ((ruleResult?.testResult != null) && (ruleResult.testResult.toLowerCase() == blob?.testResult?.toLowerCase())) {
              return ruleResult;
            }
          }
        }
      }
    }
    return null;
  }
}


///////////////////////////////
// HealthTestRule2

class HealthTestRule2 {
  final String testType;
  final String category;
  final List<HealthTestRuleResult2> results;

  HealthTestRule2({this.testType, this.category, this.results});

  factory HealthTestRule2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthTestRule2(
      testType: json['test_type'],
      category: json['category'],
      results: HealthTestRuleResult2.listFromJson(json['results']),
    ) : null;
  }

  static List<HealthTestRule2> listFromJson(List<dynamic> json) {
    List<HealthTestRule2> values;
    if (json != null) {
      values = [];
      for (dynamic entry in json) {
          try { values.add(HealthTestRule2.fromJson((entry as Map)?.cast<String, dynamic>())); }
          catch(e) { print(e?.toString()); }
      }
    }
    return values;
  }
}

///////////////////////////////
// HealthTestRuleResult2

class HealthTestRuleResult2 {
  final String testResult;
  final String category;
  final _HealthRuleStatus2 status;

  HealthTestRuleResult2({this.testResult, this.category, this.status});

  factory HealthTestRuleResult2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthTestRuleResult2(
      testResult: json['result'],
      category: json['category'],
      status: _HealthRuleStatus2.fromJson(json['status']),
    ) : null;
  }

  static List<HealthTestRuleResult2> listFromJson(List<dynamic> json) {
    List<HealthTestRuleResult2> values;
    if (json != null) {
      values = [];
      for (dynamic entry in json) {
          try { values.add(HealthTestRuleResult2.fromJson((entry as Map)?.cast<String, dynamic>())); }
          catch(e) { print(e?.toString()); }
      }
    }
    return values;
  }

  static HealthTestRuleResult2 matchRuleResult(List<HealthTestRuleResult2> results, { Covid19HistoryBlob blob }) {
    if (results != null) {
      for (HealthTestRuleResult2 result in results) {
        if (result.matchBlob(blob)) {
          return result;
        }
      }
    }
    return null;
  }

  bool matchBlob(Covid19HistoryBlob blob) {
    return ((testResult != null) && (testResult.toLowerCase() == blob?.testResult?.toLowerCase()));
  }
}

///////////////////////////////
// HealthSymptomsRule2

class HealthSymptomsRule2 {
  final Map<String, _HealthRuleIntValue2> counts;
  final _HealthRuleStatus2 status;
  
  HealthSymptomsRule2({this.counts, this.status});

  factory HealthSymptomsRule2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthSymptomsRule2(
      counts: _countsFromJson(json['counts']),
      status: _HealthRuleStatus2.fromJson(json['status']),
    ) : null;
  }

  static List<HealthSymptomsRule2> listFromJson(List<dynamic> json) {
    List<HealthSymptomsRule2> values;
    if (json != null) {
      values = [];
      for (dynamic entry in json) {
          try { values.add(HealthSymptomsRule2.fromJson((entry as Map)?.cast<String, dynamic>())); }
          catch(e) { print(e?.toString()); }
      }
    }
    return values;
  }

  static Map<String, _HealthRuleIntValue2> _countsFromJson(Map<String, dynamic> json) {
    Map<String, _HealthRuleIntValue2> values;
    if (json != null) {
      values = Map<String, _HealthRuleIntValue2>();
      json.forEach((key, value) {
        values[key] = _HealthRuleIntValue2.fromJson(value);
      });
    }
    return values;
  }

  static HealthSymptomsRule2 matchRule(List<HealthSymptomsRule2> rules, { Map<String, int> counts }) {
    if (rules != null) {
      for (HealthSymptomsRule2 rule in rules) {
        if (rule.matchCounts(counts)) {
          return rule;
        }
      }
    }
    return null;
  }

  bool matchCounts(Map<String, int> testCounts) {
    if (this.counts != null) {
      for (String groupName in this.counts.keys) {
        _HealthRuleIntValue2 value = this.counts[groupName];
        int count = (testCounts != null) ? testCounts[groupName] : null;
        if (!value.match(count)) {
          return false;
        }

      }
    }
    return true;
  }
}

///////////////////////////////
// HealthContactTraceRule2

class HealthContactTraceRule2 {
  final _HealthRuleIntValue2 duration;
  final _HealthRuleStatus2 status;

  HealthContactTraceRule2({this.duration, this.status});

  factory HealthContactTraceRule2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthContactTraceRule2(
      duration: _HealthRuleIntValue2.fromJson(json['duration']),
      status: _HealthRuleStatus2.fromJson(json['status']),
    ) : null;
  }

  static List<HealthContactTraceRule2> listFromJson(List<dynamic> json) {
    List<HealthContactTraceRule2> values;
    if (json != null) {
      values = [];
      for (dynamic entry in json) {
          try { values.add(HealthContactTraceRule2.fromJson((entry as Map)?.cast<String, dynamic>())); }
          catch(e) { print(e?.toString()); }
      }
    }
    return values;
  }

  static HealthContactTraceRule2 matchRule(List<HealthContactTraceRule2> rules, { Covid19HistoryBlob blob }) {
    if ((rules != null) && (blob != null)) {
      for (HealthContactTraceRule2 rule in rules) {
        if (rule.matchBlob(blob)) {
          return rule;
        }
      }
    }
    return null;
  }

  bool matchBlob(Covid19HistoryBlob blob) {
    return (duration != null) && duration.match(blob?.traceDurationInMinutes);
  }
}

///////////////////////////////
// HealthActionRule2

class HealthActionRule2 {
  final String type;
  final _HealthRuleStatus2 status;

  HealthActionRule2({this.type, this.status});

  factory HealthActionRule2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthActionRule2(
      type: json['type'],
      status: _HealthRuleStatus2.fromJson(json['status']),
    ) : null;
  }

  static List<HealthActionRule2> listFromJson(List<dynamic> json) {
    List<HealthActionRule2> values;
    if (json != null) {
      values = [];
      for (dynamic entry in json) {
          try { values.add(HealthActionRule2.fromJson((entry as Map)?.cast<String, dynamic>())); }
          catch(e) { print(e?.toString()); }
      }
    }
    return values;
  }

  static HealthActionRule2 matchRule(List<HealthActionRule2> rules, { Covid19HistoryBlob blob }) {
    if (rules != null) {
      for (HealthActionRule2 rule in rules) {
        if (rule.matchBlob(blob)) {
          return rule;
        }
      }
    }
    return null;
  }

  bool matchBlob(Covid19HistoryBlob blob) {
    return (type != null) && (type.toLowerCase() == blob?.actionType?.toLowerCase());
  }
}

///////////////////////////////
// _HealthRuleIntValue2

abstract class _HealthRuleIntValue2 {
  _HealthRuleIntValue2();
  
  factory _HealthRuleIntValue2.fromJson(dynamic json) {
    if (json != null) {
      if (json is int) {
        return HealthRuleIntValue2.fromJson(json);
      }
      else if (json is Map) {
        return HealthRuleIntInterval2.fromJson(json.cast<String, dynamic>());
      }
    }
    return null;
  }

  bool match(int value);
  int get min;
  int get max;
}

///////////////////////////////
// HealthRuleIntValue2

class HealthRuleIntValue2 extends _HealthRuleIntValue2 {
  final int value;
  
  HealthRuleIntValue2({this.value});

  factory HealthRuleIntValue2.fromJson(dynamic json) {
    return (json is int) ? HealthRuleIntValue2(value: json) : null;
  }

  bool match(int value) {
    return (this.value == value);
  }

  int get min { return value; }
  int get max { return value; }
}

///////////////////////////////
// HealthRuleIntInterval2

class HealthRuleIntInterval2 extends _HealthRuleIntValue2 {
  final int min;
  final int max;
  
  HealthRuleIntInterval2({this.min, this.max});

  factory HealthRuleIntInterval2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthRuleIntInterval2(
      min: json['min'],
      max: json['max'],
    ) : null;
  }

  bool match(int value) {
    return (value != null) &&
      ((min == null) || (min <= value)) &&
      ((max == null) || (max >= value));
  }
}

///////////////////////////////
// _HealthRuleStatus2

abstract class _HealthRuleStatus2 {
  
  _HealthRuleStatus2();
  
  factory _HealthRuleStatus2.fromJson(dynamic json) {
    if (json is Map) {
      if (json['condition'] != null) {
        try { return HealthTestRuleConditionalStatus2.fromJson(json.cast<String, dynamic>()); }
        catch (e) { print(e?.toString()); }
      }
      else {
        try { return HealthRuleStatus2.fromJson(json.cast<String, dynamic>()); }
        catch (e) { print(e?.toString()); }
      }
    }
    else if (json is String) {
      return HealthRuleReferenceStatus2.fromJson(json);
    }
    return null;
  }

  static Map<String, _HealthRuleStatus2> mapFromJson(Map<String, dynamic> json) {
    Map<String, _HealthRuleStatus2> result;
    if (json != null) {
      result = Map<String, _HealthRuleStatus2>();
      json.forEach((String key, dynamic value) {
        try { result[key] =  _HealthRuleStatus2.fromJson((value as Map).cast<String, dynamic>()); }
        catch (e) { print(e?.toString()); }
      });
    }
    return result;
  }

  HealthRuleStatus2 eval({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules });
}

///////////////////////////////
// HealthRuleStatus2

class HealthRuleStatus2 extends _HealthRuleStatus2 {
  final String healthStatus;
  final int priority;

  final String nextStep;
  final int nextStepInterval;

  HealthRuleStatus2({this.healthStatus, this.priority, this.nextStep, this.nextStepInterval });

  factory HealthRuleStatus2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthRuleStatus2(
      healthStatus: json['health_status'],
      priority: json['priority'],
      nextStep: json['next_step'],
      nextStepInterval: json['next_step_interval'],
    ) : null;
  }

  HealthRuleStatus2 eval({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules }) {
    return this;
  }

  bool canUpdateStatus({Covid19StatusBlob blob}) {
    int blobStatusWeight = covid19HealthStatusWeight(blob?.healthStatus);
    int newStatusWeight =  (this.healthStatus != null) ? covid19HealthStatusWeight(this.healthStatus) : blobStatusWeight;
    if (blobStatusWeight < newStatusWeight) {
      // status downgrade
      return true;
    }
    else {
      // status upgrade or preserve
      int blobStatusPriority = blob?.priority ?? 0;
      int newStatusPriority = this.priority ?? 0;
      return (newStatusPriority < 0) || (blobStatusPriority <= newStatusPriority);
    }
  }

  DateTime nextStepDateUtc(DateTime startDateUtc) {
    return ((startDateUtc != null) && (nextStepInterval != null)) ?
       startDateUtc.add(Duration(days: nextStepInterval)) : null;
  }
}

///////////////////////////////
// HealthRuleRefrenceStatus2

class HealthRuleReferenceStatus2 extends _HealthRuleStatus2 {
  final String reference;
  HealthRuleReferenceStatus2({this.reference});

  factory HealthRuleReferenceStatus2.fromJson(String json) {
    return (json != null) ? HealthRuleReferenceStatus2(
      reference: json,
    ) : null;
  }

  HealthRuleStatus2 eval({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules }) {
    _HealthRuleStatus2 status = testRules?.statuses[reference];
    return status?.eval(history: history, historyIndex: historyIndex, testRules: testRules);
  }
}

///////////////////////////////
// HealthRuleConditionalStatus2

class HealthTestRuleConditionalStatus2 extends _HealthRuleStatus2 {
  final String condition;
  final Map<String, dynamic> params;
  final _HealthRuleStatus2 successStatus;
  final _HealthRuleStatus2 failStatus;

  HealthTestRuleConditionalStatus2({this.condition, this.params, this.successStatus, this.failStatus});

  factory HealthTestRuleConditionalStatus2.fromJson(Map<String, dynamic> json) {
    return (json != null) ? HealthTestRuleConditionalStatus2(
      condition: json['condition'],
      params: json['params'],
      successStatus: _HealthRuleStatus2.fromJson(json['success']) ,
      failStatus: _HealthRuleStatus2.fromJson(json['fail']),
    ) : null;
  }

  HealthRuleStatus2 eval({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules }) {
    _HealthRuleStatus2 result;
    if (condition == 'require-test') {
      result = _evalRequireTest(history: history, historyIndex: historyIndex, testRules: testRules);
    }
    else if (condition == 'require-symptoms') {
      result = _evalRequireSymptoms(history: history, historyIndex: historyIndex, testRules: testRules);
    }
    else if (condition == 'timeout') {
      result = _evalTimeout(history: history, historyIndex: historyIndex, testRules: testRules);
    }
    return result?.eval(history: history, historyIndex: historyIndex, testRules: testRules);
  }

  _HealthRuleStatus2 _evalRequireTest({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules }) {
    
    Covid19History historyEntry = ((history != null) && (historyIndex != null) && (0 <= historyIndex) && (historyIndex < history.length)) ? history[historyIndex] : null;
    DateTime historyDateMidnightLocal = historyEntry?.dateMidnightLocal;
    if (historyDateMidnightLocal == null) {
      return null;
    }
    
    _HealthRuleIntValue2 interval = _HealthRuleIntValue2.fromJson(params['interval']);
    if (interval == null) {
      return null;
    }

    dynamic category = params['category'];
    if (category is List) {
      category = Set.from(category);
    }
    for (int index = 0; index < history.length; index++) {
      Covid19History entry = history[index];
      if ((index != historyIndex) && entry.isTest && entry.canTestUpdateStatus) {
        DateTime entryDateMidnightLocal = entry.dateMidnightLocal;
        final difference = entryDateMidnightLocal.difference(historyDateMidnightLocal).inDays;
        if (interval.match(difference)) {
          if (category == null) {
            return successStatus; // any test matches
          }
          else {
            HealthTestRuleResult2 entryRuleResult = testRules?.matchRuleResult(blob: entry?.blob);
            if ((entryRuleResult != null) && (entryRuleResult.category != null) &&
                (((category is String) && (category == entryRuleResult.category)) ||
                 ((category is Set) && category.contains(entryRuleResult.category))))
            {
              return successStatus; // only tests from given category matches
            }
          }
        }
      }
    }

    // If positive time interval is not already expired - do not return failed status yet.
    _HealthRuleIntValue2 currentInterval = _HealthRuleIntValue2.fromJson(params['current_interval']);
    if (currentInterval != null) {
      final difference = AppDateTime.todayMidnightLocal.difference(historyDateMidnightLocal).inDays;
      if (currentInterval.match(difference)) {
        return successStatus;
      }
    }

    return failStatus;
  }

  _HealthRuleStatus2 _evalRequireSymptoms({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules }) {
    Covid19History historyEntry = ((history != null) && (historyIndex != null) && (0 <= historyIndex) && (historyIndex < history.length)) ? history[historyIndex] : null;
    DateTime historyDateMidnightLocal = historyEntry?.dateMidnightLocal;
    if (historyDateMidnightLocal == null) {
      return null;
    }

    _HealthRuleIntValue2 interval = _HealthRuleIntValue2.fromJson(params['interval']);
    if (interval == null) {
      return null;
    }

    for (int index = 0; index < history.length; index++) {
      Covid19History entry = history[index];
      if ((index != historyIndex) && entry.isSymptoms) {
        DateTime entryDateMidnightLocal = entry.dateMidnightLocal;
        final difference = entryDateMidnightLocal.difference(historyDateMidnightLocal).inDays;
        if (interval.match(difference)) {
          return successStatus;
        }
      }
    }

    // If positive time interval is not already expired - do not return failed status yet.
    _HealthRuleIntValue2 currentInterval = _HealthRuleIntValue2.fromJson(params['current_interval']);
    if (currentInterval != null) {
      final difference = AppDateTime.todayMidnightLocal.difference(historyDateMidnightLocal).inDays;
      if (currentInterval.match(difference)) {
        return successStatus;
      }
    }

    return failStatus;
  }

  _HealthRuleStatus2 _evalTimeout({ List<Covid19History> history, int historyIndex, HealthTestRulesSet2 testRules }) {
    Covid19History historyEntry = ((history != null) && (historyIndex != null) && (0 <= historyIndex) && (historyIndex < history.length)) ? history[historyIndex] : null;
    DateTime historyDateMidnightLocal = historyEntry?.dateMidnightLocal;
    if (historyDateMidnightLocal == null) {
      return null;
    }

    _HealthRuleIntValue2 interval = _HealthRuleIntValue2.fromJson(params['interval']);
    if (interval == null) {
      return null;
    }

    final difference = AppDateTime.todayMidnightLocal.difference(historyDateMidnightLocal).inDays;
    return interval.match(difference) ? failStatus : successStatus; // while current time is within interval 'timeout' condition fails
  }
}

