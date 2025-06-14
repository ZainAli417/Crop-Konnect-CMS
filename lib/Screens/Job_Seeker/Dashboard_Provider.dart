import 'package:flutter/cupertino.dart';

class Job {
  final String title;
  final String company;
  final String location;
  final String salary;
  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
  });
}

class JobProvider extends ChangeNotifier {
  final List<Job> _jobs = [
    Job(title: 'Flutter Developer', company: 'TechCorp', location: 'Remote', salary: '\$80k - \$100k'),
    Job(title: 'UI/UX Designer', company: 'Designify', location: 'New York, NY', salary: '\$70k - \$90k'),
    Job(title: 'Backend Engineer', company: 'DataSolve', location: 'San Francisco, CA', salary: '\$90k - \$120k'),
    Job(title: 'Product Manager', company: 'InnovateX', location: 'Chicago, IL', salary: '\$85k - \$110k'),
  ];
  List<Job> get jobs => _jobs;
}
