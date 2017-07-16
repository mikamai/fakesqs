# Fake SQS [![Build Status](https://secure.travis-ci.org/tiwilliam/fakesqs.png)](http://travis-ci.org/tiwilliam/fakesqs)

Fake SQS is a lightweight server that mocks the Amazon SQS API.

It is extremely useful for testing SQS applications in a sandbox environment without actually
making calls to Amazon, which not only requires a network connection, but also costs
money.

Many features are supported and if you miss something, open a pull.

This is a maintained fork of [iain/fake_sqs](https://github.com/iain/fake_sqs).

## Installation

```
gem install fakesqs
```

## Running

```
fakesqs --database /path/to/database.yml
```

## Development

```
bundle install
rake
```
